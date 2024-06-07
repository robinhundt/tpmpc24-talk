class BaseLayerIter:
  graph: Graph,
  inputs_needed: [int]
  next_layer: Queue<Id>
  current_layer: Queue<Id>
  prev_interactive: Queue<Id>

  def __init__(self, i, G, I, O):
    self.graph = G
    self.inputs_needed = [len(pred(v)) for v in G.V] 
    self.next_layer = Queue()
    self.current_layer = Queue()
    self.prev_interactive = Queue()

  # decrement successors' inputs_needed of v and add to queue if 
  # no more inputs are needed
  def add_ready_successors(self, v, queue):
    for s in succ(v):
      self.inputs_needed[s] -= 1
      if self.inputs_needed[s] == 0:
        queue.push_back(s)

  # returns next layer in topological order or None
  def next(self):
    # next layer queue becomes the current layer
    swap(next_layer, current_layer)
    # current layer is empty, as we popped all elements
    # in previous iteration
    layer = Layer()

    # check previous interactive gates successors for current layer
    while v = prev_interactive.pop_front():
      self.add_ready_successors(v, inputs_needed, current_layer)
    
    # pop from the front of the queue until empty
    while v = current_layer.pop_front():
      if G.is_interactive(v):
        layer.push_interactive(v)
        # consider successors in **next** iteration
        self.prev_interactive.push_back(v)
      else:
        layer.push_non_interactive(v)
        # potentially add successors of non-interactive gate to
        # **current layer** 
        self.add_ready_successors(v, inputs_needed, current_layer)
        
    if layer.is_empty():
      # we have yielded all gates and this iterator is exhausted
      return None
    else:
      # this layer can be evaluated in one round
      return layer