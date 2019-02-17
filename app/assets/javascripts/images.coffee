# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

connectMasonryLayout = (listElement) ->
  doLayout = () ->
    columnWidth = null
    numColumns = null
    totalWidth = listElement.getBoundingClientRect().width
    widthRemaining = totalWidth
    columnHeights = {}
    childPositions = new Map

    getColumnLeftPos = (columnNumber) ->
      if columnWidth == null
        throw Error "Cannot call getColumnLeftPos before the first child rect is processed and columnWidth is found."
      leftMargin = (totalWidth % columnWidth) / 2
      columnOffset = columnNumber * columnWidth
      leftMargin + columnOffset

    children = listElement.children
    for i in [0...children.length]
      child = children[i]
      childRect = child.getBoundingClientRect()
      if columnWidth == null
        columnWidth = childRect.width
        numColumns = Math.floor(totalWidth / columnWidth)
        for i in [0...numColumns]
          columnHeights[i] = 0
      else if childRect.width != columnWidth
        console.warn "Bad width child", child, "width:", childWidth

      column = 0
      for i in [0...numColumns]
        if columnHeights[i] < columnHeights[column]
          column = i

      childPositions.set child, {
        x: getColumnLeftPos column
        y: columnHeights[column]
      }

      columnHeights[column] += childRect.height

    childPositions.forEach ({x, y}, child) ->
      child.style.position = "absolute"
      child.style.left = "#{x}px"
      child.style.top = "#{y}px"

    maxHeight = 0
    for _column, height of columnHeights
      if height > maxHeight
        maxHeight = height

    listElement.style.height = "#{maxHeight}px"

  listElement.layoutNewChildren = () ->
    for i in [0...listElement.children.length]
      listElement.children[i].style.position = "absolute"
    doLayout()

  # TODO: redo this on child added or removed
  listElement.layoutNewChildren()

  resizeTimeout = null
  window.addEventListener "resize", () ->
    clearTimeout(resizeTimeout)
    resizeTimeout = setTimeout(doLayout, 400)

document.addEventListener "turbolinks:load", () ->
  list = document.querySelector(".list")
  # TODO: wait until all images have their sizes
  connectMasonryLayout list if list != null
