


class Node

include Comparable

  attr_accessor :data, :left, :right

  def initialize data=nil, left=nil, right=nil
    @data = data
    @left = left
    @right = right
  end

  def <=> other
    return self.data <=> other.data
  end

  def to_s
    "data: #{data}"
  end

  def left?
    left.nil? ? false : true
  end

  def right?
    right.nil? ? false : true
  end
end

class Tree

  attr_accessor :root

  def initialize ary
    @root = Tree.build_tree ary
  end

  def find value,node=@root
    return nil if node.nil?
    return node if node.data == value
    find(value,node.left) || find(value,node.right)
  end

  def depth node=@root
    depth = 0
    return depth if node.nil?
    depth += 1 if node.left? || node.right?
    depth += [depth(node.left),depth(node.right)].max
  end

  def insert value
    return false if find(value)
    _insert(value)
  end

  def delete value
    #if it's a leaf, just delete the reference to it
    #if it has one child, link its parent and child
    #if it has two children...promote the left child,
    #then the left child's right child,
    #then the left child's right child's left child, and so on.
    return false if !find(value)

    nodeToDelete = find(value)
    if nodeToDelete.left? && nodeToDelete.right?
      #do the hard deletion
      if depth(root.left) >= depth(root.right)
        temp_node = nodeToDelete.right
        nodeToDelete = nodeToDelete.left
        newParent = nodeToDelete #change name to make the rest more obvious
        while newParent.right?
          newParent = newParent.right
        end
        newParent.right = temp_node
      else
        temp_node = nodeToDelete.left
        nodeToDelete = nodeToDelete.right #change name to make the rest more obvious
        newParent = nodeToDelete
        while newParent.left?
          newParent = newParent.left
        end
        newParent.left = temp_node
      end

    elsif nodeToDelete.left?
      #node only has a left child
      nodeToDelete = nodeToDelete.left

    elsif nodeToDelete.right?
      #node only has a right child
      nodeToDelete = nodeToDelete.right

    else
      #node is a leaf
      nodeToDelete = nil
    end
  end

  def level_order
    queue = [@root]
    dataArray = []
    until queue.empty?
      node = queue.pop
      if block_given?
        yield(node)
      else
        dataArray << node.data
      end
      queue.unshift(node.left) if node.left?
      queue.unshift(node.right) if node.right?
    end
    unless block_given?
      return dataArray
    end
  end

=begin
  def inorder
    stack = [root]
    #left, node, right
    #
    #push left onto stack
    #go to left node, push left onto stack again.
    #keep going until no more left nodes
    #process node
    #push right node onto stack
    #go to left node, push left onto stack again
    #keep going left until no more left nodes.
    #process node
    #push right node onto stack

    dataArray = []
    node = root
    until stack.empty?
      while node.left?
        node = node.left
        stack << node
      end
      node = stack.pop
      if block_given?
        yield(node)
      else
        dataArray << node.data
      end
      if node.right?
        node = node.right
        stack << node
      end
    end
    unless block_given?
      return dataArray
    end
  end
=end

  def inorder node=@root, &block
    dataArray = []
    dataArray << inorder(node.left,&block) if node.left?
    block_given? ? yield(node) : dataArray << node.data
    dataArray << inorder(node.right,&block) if node.right?
    unless block_given?
      return dataArray.flatten
    end
  end

  def preorder node=@root, &block
    dataArray = []
    block_given? ? yield(node) : dataArray << node.data
    dataArray << preorder(node.left,&block) if node.left?
    dataArray << preorder(node.right,&block) if node.right?
    unless block_given?
      return dataArray.flatten
    end
  end

  def postorder node=@root, &block
    dataArray = []
    dataArray << postorder(node.left, &block) if node.left?
    dataArray << postorder(node.right, &block) if node.right?
    block_given? ? yield(node) : dataArray << node.data
    unless block_given?
      return dataArray.flatten
    end
  end


  def balanced?
    (depth(@root.left) - depth(@root.right)).abs <= 1 ? true : false
  end

  def rebalance!
    newTree = Tree.new(self.level_order)
    @root = newTree.root
  end







  def self.build_tree dataArray
  #takes array of values, creates a balanced tree, and returns the root node

    sortedArray = dataArray.sort

    sortedArray = sortedArray.uniq.nil? ? sortedArray : sortedArray.uniq

    rootIndex = sortedArray.length/2

    root = Node.new(sortedArray[rootIndex],
    build_subtree(sortedArray[0...rootIndex]),
    build_subtree(sortedArray[rootIndex+1..-1]))
    return root
  end

  private


  def _insert(value,node=@root)
    if value < node.data
      node.left.nil? ? node.left = Node.new(value) : _insert(value,node.left)
    else
      node.right.nil? ? node.right = Node.new(value) : _insert(value,node.right)
    end
  end



  def self.build_subtree sortedArray
    return Node.new(sortedArray[0]) if sortedArray.length == 1
    return nil                      if sortedArray.length == 0

    nodeIndex = sortedArray.length/2

    node = Node.new(sortedArray[nodeIndex],
    build_subtree(sortedArray[0...nodeIndex]),
    build_subtree(sortedArray[nodeIndex+1..-1]))
  end
end

def print_orders tree

  print "inorder: "
  print tree.inorder
  puts ""

  print "preorder: "
  print tree.preorder
  puts ""

  print "postorder: "
  print tree.postorder
  puts ""

end


#ary = [1, 3, 4, 5, 7, 8, 9, 15, 16, 17, 18, 23, 67, 324, 6345]

tree = Tree.new(Array.new(15) {rand(1..100)})
print "is tree balanced? "
puts tree.balanced?

print_orders(tree)

10.times{
  tree.insert(rand(100..200))
}
print "inorder"
print tree.inorder
puts ""

print "is tree balanced? "
puts tree.balanced?

puts "rebalancing..."
tree.rebalance!

print "inorder"
print tree.inorder
puts ""

print "is tree balanced? "
puts tree.balanced?

print_orders(tree)
