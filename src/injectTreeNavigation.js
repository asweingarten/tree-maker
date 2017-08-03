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

module.exports = TreeNavigation;
