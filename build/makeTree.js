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
  const geometry = element.getBoundingClientRect();
  if (geometry.height === 0 || geometry.width === 0) {
    return null;
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
