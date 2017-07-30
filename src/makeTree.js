// Returns a pared down DOM-tree
export default function makeTree(element, parent) {
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

  const geometry = element.getBoundingClientRect();
  if (isOffScreen(node)) {
    return null;
  }
  // if (geometry.height === 0 || geometry.width === 0) {
  //   console.log(`SKIPPING: ${element.id} ${geometry}`)
  //   return null;
  // }
  // if (element.id === 'appbar-nav') {
  //   console.log('APPBAR NAV')
  //   console.log(geometry)
  // }

  const children = asArray(element.children);


  let subRegions = children.map(c => makeTree(c, node)).filter(r => r !== null);

  // if a non-clickable has no children, then we don't want it
  if (subRegions.length === 0) {
    return null;
  } else if (subRegions.length === 1) {
    const onlyChild = subRegions[0];
    onlyChild.parent = parent;
    return onlyChild;
  }

  // inspect children, if one is zero-height, then bring it's children into the list.
  subRegions = subRegions.map(r => {
    if (isZeroHeight(r)) {
      return r.children;
    } else {
      return r;
    }
  });

  // flatten the array
  subRegions = [].concat.apply([], subRegions);

  // else return
  node.children = subRegions;
  return node;

}

function isOffScreen(node) {
  const el = node.element;
  const geometry = el.getBoundingClientRect();
  return (
    geometry.left + geometry.width <= 0
    || geometry.right < 0
  );

}

function isZeroHeight(node) {
  const el = node.element;
  const geometry = el.getBoundingClientRect();
  return geometry.height === 0;
}

function asArray(htmlCollection) {
  return [].slice.call(htmlCollection);
}
