let highlightIndex = 0;
function createHighlight(elementToHighlight, color='salmon', isTarget=false) {
  const clientRect = elementToHighlight.getBoundingClientRect();

  const borderWeight = 3;
  const highlight = document.createElement('div');
  highlight.class = `HIGHLIGHT-${highlightIndex}`;
  highlightIndex += 1; // global var
  highlight.style.position = 'fixed';
  if (isTarget) {
    highlight.style.left = `${clientRect.left - 2*borderWeight}px`;
    highlight.style.top = `${clientRect.top - 2*borderWeight}px`;

    highlight.style.width = `${elementToHighlight.offsetWidth + 2*borderWeight}px`;
    highlight.style.height = `${elementToHighlight.offsetHeight + 2*borderWeight}px`;
  } else {
    highlight.style.left = `${clientRect.left}px`;
    highlight.style.top = `${clientRect.top}px`;

    highlight.style.width = `${elementToHighlight.offsetWidth - borderWeight}px`;
    highlight.style.height = `${elementToHighlight.offsetHeight - borderWeight}px`;
  }
  highlight.style.border = `3px solid ${color}`;
  highlight.style['border-radius'] = `${borderWeight}px`;
  highlight.style['z-index'] = 2999999999;


  return {
    highlight,
    el: elementToHighlight
  };
}
