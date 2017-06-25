// @TODO
// - preview what children will be cyclable
// - auto highlight first child when making a selection

var state = {
    currentNode: makeTree(document.body),
    currentChildIndex: -1,
    highlights: [createHighlight(makeTree(document.body).element)]
}

document.addEventListener('keydown', e => {
  if (e.key === 'Tab') {
    e.preventDefault();
    // cycle through children

    // increment currentChildIndex and remove highlight
    state.currentChildIndex = (state.currentChildIndex + 1) % state.currentNode.children.length;
    state.highlights[state.highlights.length-1].highlight.remove();
    state.highlights = state.highlights.slice(0, state.highlights.length-1);

    // highlight new currentChild
    const {highlight, el} = createHighlight(state.currentNode.children[state.currentChildIndex].element);
    state.highlights.push({highlight, el});
    document.body.append(highlight);

  }
});

document.addEventListener('keydown', e => {
  if (e.key === 'Enter') {
    // move down tree
    state.currentNode = state.currentNode.children[state.currentChildIndex];
    state.currentChildIndex = -1;

    // if leaf node, then click
    if (state.currentNode.children.length === 0) {

    }
  }
});

document.addEventListener('keydown', e => {
  if (e.key === 'Tab' && e.shiftKey) {
    // move up tree
    state.currentNode = currentNode.parent;
  }
});


// Returns a pared down DOM-tree
function makeTree(element, parent) {
  // if leaf node, return right away. Doesn't matter if images or w/e is tucked away inside
  if (element.nodeName === 'A' || element.nodeName === 'BUTTON') {
    return {
      parent,
      element,
      children: []
    };
  }

  const children = asArray(element.children);


  const subRegions = children.map(c => makeTree(c, element)).filter(r => r !== null);

  // if a non-clickable has no children, then we don't want it
  if (subRegions.length === 0) {
    return null;
  } else if (subRegions.length === 1) {
    const onlyChild = subRegions[0];
    onlyChild.parent = parent;
    return onlyChild;
  }

  // else return
  return {
    parent,
    element,
    children: subRegions
  };

}

function asArray(htmlCollection) {
  return [].slice.call(htmlCollection);
}
