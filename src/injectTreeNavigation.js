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
  currentNode: makeTree(document.body),
  currentChildIndex: -1,
}

console.log(state.currentNode);

TreeNavigation.ports.select.subscribe((time) => {
  const currentlyHighlightedNode = state.currentNode.children[state.currentChildIndex];

  if (currentlyHighlightedNode.children.length === 0) {
    // Click but don't make it the current node
    currentlyHighlightedNode.element.click();
  } else {
    state.currentNode = state.currentNode.children[state.currentChildIndex];
    state.currentChildIndex = 0;
    const elementToHighlight = state.currentNode.children[0].element;
    highlight(elementToHighlight);
  }
  // console.log('SELECT');
  // if (state.currentNode.children.length === 0) {
  //   return;
  // }
  //
  // // move down tree
  // state.currentNode = state.currentNode.children[state.currentChildIndex];
  // state.currentChildIndex = 0;
  //
  // // if leaf node, then click
  // if (state.currentNode.children.length === 0) {
  //   state.currentNode.element.click();
  // } else {
  //   const elementToHighlight = state.currentNode.children[0].element;
  //   highlight(elementToHighlight);
  // }
});

TreeNavigation.ports.next.subscribe((time) => {
  console.log('NEXT');
  // increment currentChildIndex and remove highlight
  state.currentChildIndex = (state.currentChildIndex + 1) % state.currentNode.children.length;
  const elementToHighlight = state.currentNode.children[state.currentChildIndex].element;
  highlight(elementToHighlight);
  console.log(state.currentNode.children[state.currentChildIndex]);
});

TreeNavigation.ports.previous.subscribe((time) => {
  console.log('PREVIOUS');
  // decrement currentChildIndex and remove highlight
  state.currentChildIndex = (state.currentChildIndex - 1);
  if (state.currentChildIndex < 0) {
    state.currentChildIndex = state.currentNode.children.length - 1
  }

  const elementToHighlight = state.currentNode.children[state.currentChildIndex].element;
  highlight(elementToHighlight);
  // console.log(state.currentNode.children[state.currentChildIndex]);
});

TreeNavigation.ports.up.subscribe((x) => {
  console.log('UP');
  if (state.currentNode.parent) {
    state.currentChildIndex = 0;
    state.currentNode = state.currentNode.parent;
    highlight(state.currentNode.children[state.currentChildIndex].element)
  }
});

function highlight(element) {
  const boundingBox = element.getBoundingClientRect();
  console.log(boundingBox);
  TreeNavigation.ports.highlight.send({
    x: ~~boundingBox.left,
    y: ~~boundingBox.top,
    width: ~~element.offsetWidth,
    height: ~~element.offsetHeight
  });
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


// MUTATIONS

const mutationObserver = new MutationObserver(onMutation);
  // (mutationRecords, observer) => { console.log(mutationRecords);}
// );

mutationObserver.observe(document.body, {
  childList: true,
  // attributes: true,
  // characterData: true,
  subtree: true,
  // attributeOldValue: true,

})

// Data race with key presses....
function onMutation(mutationRecords, observer) {
  console.log('MUTATION');
  const newTree = makeTree(document.body);

  // don't access the children if it's a leaf node.
  const equivNode = findEquivalentNode(newTree, state.currentNode);
  if (!equivNode) {
    state.currentNode = newTree;
    state.currentChildIndex = 0;
    highlight(state.currentNode.children[state.currentChildIndex].element);
  } else {
    state.currentNode = equivNode;
    if (state.currentNode.children.length === 0) {
      highlight(state.currentNode.element);
    } else {
      highlight(state.currentNode.children[state.currentChildIndex].element);
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
