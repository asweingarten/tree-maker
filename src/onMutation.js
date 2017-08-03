const _ = require('./lodash.custom.min.js');
const makeTree = require('./makeTree.js');
const Actions = {
  UP: 'UP',
  NEXT: 'NEXT',
  PREVIOUS: 'PREVIOUS',
  SELECT: 'SELECT',
  NOOP: 'NO-OP'
}
// Data race with key presses....

function createMutationObserver(state, highlight) {
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

  const debouncedOnMutation = _.debounce(onMutation, 100)
  const mutationObserver = new MutationObserver(debouncedOnMutation);
  return mutationObserver;

}

module.exports = createMutationObserver;
