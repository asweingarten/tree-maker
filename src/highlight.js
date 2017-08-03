const _ = require('./lodash.custom.min');

function highlight(TreeNavigation, action, activeNode) {
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

module.exports = (TreeNavigation) => {
  return highlight.bind(this, TreeNavigation);
}
