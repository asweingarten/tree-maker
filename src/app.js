const _ = require('./lodash.custom.min');
const makeTree = require('./makeTree.js');
const TreeNavigation = require('./injectTreeNavigation.js');
const highlight = require('./highlight.js')(TreeNavigation);
const createMutationObserver = require('./onMutation.js');

const Actions = {
  UP: 'UP',
  NEXT: 'NEXT',
  PREVIOUS: 'PREVIOUS',
  SELECT: 'SELECT',
  NOOP: 'NO-OP'
}

let state = createState(document.body);

let mutationObserver = createMutationObserver(state, highlight);

select();

console.log(state.currentNode);

window.addEventListener("click", (event) => TreeNavigation.ports.clicks.send({ x: ~~event.clientX, y: ~~event.clientY}))
window.addEventListener("mousemove", (event) => TreeNavigation.ports.moves.send({ x: ~~event.clientX, y: ~~event.clientY}));

// PageChange
TreeNavigation.ports.switchTree.subscribe(page => {
  mutationObserver.disconnect();
  let root;
  if (page === 'Website') {
    root = () => document.body;
  } else if (page === 'ScanningSettingsPage') {
    root = () => document.getElementById('tn-settings');
  }
  setTimeout(() => {
    console.log(root());
    state = createState(root());
    select();
    mutationObserver = createMutationObserver(state, highlight);
  }, 100);
})

// SCROLLING
TreeNavigation.ports.scrollIntoView.subscribe(isTall => {
  console.log("SCROLL TIME");
  const regionInFocus = state.currentNode.children[state.currentChildIndex].element;
  regionInFocus.scrollIntoView(isTall)
  if (isTall) {
    window.scrollBy(0, -100);
  }
  highlight(Actions.NOOP, state.currentNode.children[state.currentChildIndex]);
});

TreeNavigation.ports.select.subscribe(select);
TreeNavigation.ports.next.subscribe(next)
TreeNavigation.ports.previous.subscribe(previous)
TreeNavigation.ports.up.subscribe(up);

// TreeNavigation.ports.commandFired.subscribe(direction => {
//   TreeNavigation.ports.resumeScanning.send('x');
// })

TreeNavigation.ports.activated.subscribe(x => TreeNavigation.ports.pauseScanning.send('x'));


function createState(rootNode) {
  return {
    currentNode: {
      parent: undefined,
      children: [makeTree(rootNode)],
      element: rootNode
    },
    currentChildIndex: 0,
  }
}

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
