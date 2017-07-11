// Returns a pared down DOM-tree
function makeTree(element, parent) {
  // if leaf node, return right away. Doesn't matter if images or w/e is tucked away inside
  let node = {
    parent,
    element,
    children: []
  };



  if (element.nodeName === 'A' || element.nodeName === 'BUTTON') {
    const geometry = element.getBoundingClientRect();
    if (geometry.width === 0 || geometry.height === 0) {
      return null;
    }
    return node
  }

  // const geometry = element.getBoundingClientRect();
  // if (geometry.height === 0 || geometry.width === 0) {
  //   console.log(`SKIPPING: ${element.id} ${geometry}`)
  //   return null;
  // }
  // if (element.id === 'appbar-nav') {
  //   console.log('APPBAR NAV')
  //   console.log(geometry)
  // }

  const children = asArray(element.children);


  const subRegions = children.map(c => makeTree(c, node)).filter(r => r !== null);

  // if a non-clickable has no children, then we don't want it
  if (subRegions.length === 0) {
    return null;
  } else if (subRegions.length === 1) {
    const onlyChild = subRegions[0];
    onlyChild.parent = parent;
    return onlyChild;
  }

  // else return
  node.children = subRegions;
  return node;

}

function asArray(htmlCollection) {
  return [].slice.call(htmlCollection);
}
