/*************************************************************************
 *
 * Copyright 2016 Realm Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **************************************************************************/

#ifndef REALM_CLUSTER_TREE_HPP
#define REALM_CLUSTER_TREE_HPP

#include <realm/cluster.hpp>
#include <realm/util/function_ref.hpp>

namespace realm {

class Cluster;

class ClusterTree {
public:
    class Iterator;
    using TraverseFunction = util::FunctionRef<bool(const Cluster*)>;
    using UpdateFunction = util::FunctionRef<void(Cluster*)>;
    using ColIterateFunction = util::FunctionRef<bool(ColKey)>;

    ClusterTree(Allocator& alloc);
    virtual ~ClusterTree();

    ClusterTree(ClusterTree&&) = default;

    // Disable copying, this is not allowed.
    ClusterTree& operator=(const ClusterTree&) = delete;
    ClusterTree(const ClusterTree&) = delete;

    bool is_attached() const
    {
        return m_root->is_attached();
    }
    Allocator& get_alloc() const
    {
        return m_alloc;
    }

    void init_from_parent();
    void update_from_parent() noexcept;

    size_t size() const noexcept
    {
        return m_size;
    }

    static size_t size_from_ref(ref_type, Allocator& alloc);

    void destroy()
    {
        m_root->destroy_deep();
    }
    void nullify_links(ObjKey, CascadeState&);
    bool is_empty() const noexcept
    {
        return size() == 0;
    }
    int64_t get_last_key_value() const
    {
        return m_root->get_last_key_value();
    }
    MemRef ensure_writeable(ObjKey k)
    {
        return m_root->ensure_writeable(k);
    }
    Array& get_fields_accessor(Array& fallback, MemRef mem) const
    {
        if (m_root->is_leaf()) {
            return *m_root;
        }
        fallback.init_from_mem(mem);
        return fallback;
    }

    uint64_t bump_content_version()
    {
        return m_alloc.bump_content_version();
    }
    void bump_storage_version()
    {
        m_alloc.bump_storage_version();
    }
    uint64_t get_content_version() const
    {
        return m_alloc.get_content_version();
    }
    uint64_t get_instance_version() const
    {
        return m_alloc.get_instance_version();
    }
    uint64_t get_storage_version(uint64_t inst_ver) const
    {
        return m_alloc.get_storage_version(inst_ver);
    }
    void insert_column(ColKey col)
    {
        m_root->insert_column(col);
    }
    void remove_column(ColKey col)
    {
        m_root->remove_column(col);
    }

    // Insert entry for object, but do not create and return the object accessor
    void insert_fast(ObjKey k, const FieldValues& init_values, ClusterNode::State& state);
    // Create and return object
    ClusterNode::State insert(ObjKey k, const FieldValues&);
    // Delete object with given key
    void erase(ObjKey k, CascadeState& state);
    // Check if an object with given key exists
    bool is_valid(ObjKey k) const;
    // Lookup and return object
    ClusterNode::State get(ObjKey k) const;
    // Lookup and return object
    ClusterNode::State try_get(ObjKey k) const noexcept;
    // Lookup by index
    ClusterNode::State get(size_t ndx, ObjKey& k) const;
    // Get logical index of object identified by k
    size_t get_ndx(ObjKey k) const;
    // Find the leaf containing the requested object
    bool get_leaf(ObjKey key, ClusterNode::IteratorState& state) const noexcept;
    // Visit all leaves and call the supplied function. Stop when function returns true.
    // Not allowed to modify the tree
    bool traverse(TraverseFunction func) const;
    // Visit all leaves and call the supplied function. The function can modify the leaf.
    void update(UpdateFunction func);

    virtual void for_each_and_every_column(ColIterateFunction) const = 0;
    virtual void update_indexes(ObjKey k, const FieldValues& init_values) = 0;
    virtual void cleanup_key(ObjKey k) = 0;
    virtual void set_spec(ArrayPayload& arr, ColKey::Idx col_ndx) const = 0;
    virtual bool is_string_enum_type(ColKey::Idx col_ndx) const = 0;
    virtual const Table* get_owning_table() const = 0;
    virtual std::unique_ptr<ClusterNode> get_root_from_parent() = 0;

    void dump_objects()
    {
        m_root->dump_objects(0, "");
    }
    void verify() const;

protected:
    friend class Obj;
    friend class Cluster;
    friend class ClusterNodeInner;

    Allocator& m_alloc;

    std::unique_ptr<ClusterNode> m_root;
    size_t m_size = 0;

    void clear();
    void replace_root(std::unique_ptr<ClusterNode> leaf);

    std::unique_ptr<ClusterNode> create_root_from_parent(ArrayParent* parent, size_t ndx_in_parent);
    std::unique_ptr<ClusterNode> get_node(ArrayParent* parent, size_t ndx_in_parent) const;
};

class ClusterTree::Iterator {
public:
    Iterator(const ClusterTree& t, size_t ndx);
    Iterator(const Iterator& other);

    Iterator& operator=(const Iterator& other)
    {
        REALM_ASSERT(&m_tree == &other.m_tree);
        m_position = other.m_position;
        m_key = other.m_key;
        m_leaf_invalid = true;

        return *this;
    }

    ObjKey go(size_t n);
    bool update() const;
    // Advance the iterator to the next object in the table. This also holds if the object
    // pointed to is deleted. That is - you will get the same result of advancing no matter
    // if the previous object is deleted or not.
    Iterator& operator++();

    Iterator& operator+=(ptrdiff_t adj);

    bool operator==(const Iterator& rhs) const
    {
        return m_key == rhs.m_key;
    }
    bool operator!=(const Iterator& rhs) const
    {
        return m_key != rhs.m_key;
    }

protected:
    const ClusterTree& m_tree;
    mutable uint64_t m_storage_version = uint64_t(-1);
    mutable Cluster m_leaf;
    mutable ClusterNode::IteratorState m_state;
    mutable uint64_t m_instance_version = uint64_t(-1);
    ObjKey m_key;
    mutable bool m_leaf_invalid;
    mutable size_t m_position;
    mutable size_t m_leaf_start_pos = size_t(-1);

    ObjKey load_leaf(ObjKey key) const;
    size_t get_position();
};
}

#endif /* REALM_CLUSTER_TREE_HPP */
