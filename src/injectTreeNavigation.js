const Actions = {
  UP: 'UP',
  NEXT: 'NEXT',
  PREVIOUS: 'PREVIOUS',
  SELECT: 'SELECT',
  NOOP: 'NO-OP'
}

const treeNavDiv = document.createElement('div');
treeNavDiv.id = 'tree-navigation';
treeNavDiv.style.position  ='fixed';
var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
treeNavDiv.style.width = w;
treeNavDiv.style.height = h;
treeNavDiv.style['z-index'] = 2000000001;
treeNavDiv.style['pointer-events'] = 'none';

document.body.appendChild(treeNavDiv);

const TreeNavigation = Elm.TreeNavigation.embed(treeNavDiv);

document.onkeydown = (e) => {
  if (e.key === 'Tab' || e.key === 'Enter') {
    e.preventDefault();
  }
}

state = {
  currentNode: {
    parent: undefined,
    children: [makeTree(document.body)],
    element: document.body
  },
  currentChildIndex: 0,
}

select();

console.log(state.currentNode);

// MUTATIONS
const debouncedOnMutation = _.debounce(onMutation, 100)
const mutationObserver = new MutationObserver(debouncedOnMutation);

mutationObserver.observe(document.body, {
  childList: true,
  subtree: true,
})

TreeNavigation.ports.select.subscribe(select);
TreeNavigation.ports.next.subscribe(next)
TreeNavigation.ports.previous.subscribe(previous)
TreeNavigation.ports.up.subscribe(up);

function select(foo) {
  if (!state) return;

  const currentlyHighlightedNode = state.currentNode.children[state.currentChildIndex];
  if (!currentlyHighlightedNode) return;

  if (currentlyHighlightedNode.children.length === 0) {
    // Click but don't make it the current node
    currentlyHighlightedNode.element.click();
  } else if (currentlyHighlightedNode.children.length === 1) {
    currentlyHighlightedNode.children[0].element.click();
  } else {
    state.currentNode = state.currentNode.children[state.currentChildIndex];
    state.currentChildIndex = 0;
    highlight(Actions.SELECT, state.currentNode.children[0]);
  }
}

function next(foo) {
  console.log('NEXT');
  // increment currentChildIndex and remove highlight
  state.currentChildIndex = (state.currentChildIndex + 1) % state.currentNode.children.length;
  const elementToFocus = state.currentNode.children[state.currentChildIndex].element;
  elementToFocus.focus();
  highlight(Actions.NEXT, state.currentNode.children[state.currentChildIndex]);
  // console.log(state.currentNode.children[state.currentChildIndex]);
}

function previous(foo) {
  console.log('PREVIOUS');
  // decrement currentChildIndex and remove highlight
  state.currentChildIndex = (state.currentChildIndex - 1);
  if (state.currentChildIndex < 0) {
    state.currentChildIndex = state.currentNode.children.length - 1
  }

  const elementToFocus = state.currentNode.children[state.currentChildIndex].element;
  elementToFocus.focus();
  highlight(Actions.PREVIOUS, elementToHighlight);
}

function up(foo) {
  console.log('UP');
  if (state.currentNode.parent) {
    state.currentChildIndex = 0;
    state.currentNode = state.currentNode.parent;
    highlight(Actions.UP, state.currentNode.children[state.currentChildIndex])
  }
}

function highlight(action, activeNode) {
  const activeRegion = computeGeometry(activeNode.element);
  const childRegions = activeNode.children.map(c => computeGeometry(c.element));
  const siblingRegions = !activeNode.parent ? [] : activeNode.parent.children
    .map(c => computeGeometry(c.element))
    .filter(x => !_.isEqual(x, activeRegion));
  TreeNavigation.ports.regions.send({
    action,
    activeRegion,
    childRegions,
    siblingRegions
  });
}

function computeGeometry(element) {
  const boundingBox = element.getBoundingClientRect();
  return {
    x: ~~boundingBox.left,
    y: ~~boundingBox.top,
    width: ~~element.offsetWidth,
    height: ~~element.offsetHeight
  };

}

// SCROLLING
TreeNavigation.ports.scrollIntoView.subscribe(isTall => {
  console.log("SCROLL TIME");
  const regionInFocus = state.currentNode.children[state.currentChildIndex].element;
  regionInFocus.scrollIntoView(isTall)
  if (isTall) {
    window.scrollBy(0, -100);
  }
});




// Data race with key presses....
function onMutation(mutationRecords, observer) {
  console.log('MUTATION');
  const newTree = makeTree(document.body);

  // don't access the children if it's a leaf node.
  const equivNode = findEquivalentNode(newTree, state.currentNode);
  if (!equivNode) {
    state.currentNode = newTree;
    state.currentChildIndex = 0;
    highlight(Actions.SELECT, state.currentNode.children[state.currentChildIndex]);
  } else {
    state.currentNode = equivNode;
    if (state.currentNode.children.length === 0) {
      highlight(Actions.NOOP, state.currentNode);
    } else {
      highlight(Actions.NOOP, state.currentNode.children[state.currentChildIndex]);
    }
  }

  // current node should be maintained if it's still on the page.
  // else go to top
}

function findEquivalentNode(tree, node) {
  if (tree.element.isEqualNode(node.element)) {
    return tree;
  }

  const foundNodes = tree.children.map((c) => findEquivalentNode(c, node)).filter(x => x);

  if (foundNodes.length === 0) {
    return undefined;
  } else {
    return foundNodes[0];
  }
}
