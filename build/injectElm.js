const elmDiv = document.createElement('div');
elmDiv.id = 'eyegaze-overlay';
elmDiv.style.position  ='fixed';
var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
elmDiv.style.width = w;
elmDiv.style.height = h;
elmDiv.style['z-index'] = 2000000001;

document.body.appendChild(elmDiv);

const app = Elm.TreeNavigation.embed(elmDiv);

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

app.ports.select.subscribe((time) => {
  console.log('ENTER');
  // move down tree
  state.currentNode = state.currentNode.children[state.currentChildIndex];
  state.currentChildIndex = 0;

  // if leaf node, then click
  if (state.currentNode.children.length === 0) {
    state.currentNode.element.click();
  } else {
    const elementToHighlight = state.currentNode.children[0].element;
    highlight(elementToHighlight);
  }
});

app.ports.next.subscribe((time) => {
  console.log('TAB');
  // increment currentChildIndex and remove highlight
  state.currentChildIndex = (state.currentChildIndex + 1) % state.currentNode.children.length;
  const elementToHighlight = state.currentNode.children[state.currentChildIndex].element;
  highlight(elementToHighlight);
  console.log(state.currentNode.children[state.currentChildIndex]);

});

app.ports.up.subscribe((x) => {
  console.log('SHIFT + TAB');
  if (state.currentNode.parent) {
    state.currentChildIndex = 0;
    state.currentNode = state.currentNode.parent;
    highlight(state.currentNode)
  }
});

function highlight(element) {
  const boundingBox = element.getBoundingClientRect();
  console.log(boundingBox);
  app.ports.highlight.send({
    x: ~~boundingBox.left,
    y: ~~boundingBox.top,
    width: ~~element.offsetWidth,
    height: ~~element.offsetHeight
  });
}
