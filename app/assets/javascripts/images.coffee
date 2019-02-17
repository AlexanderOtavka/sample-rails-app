# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Layout the children of listElement in a masonry style (like pinterest)
# listElement must not be position static
connectMasonryLayout = (listElement) ->
  if getComputedStyle(listElement).getPropertyValue("position") == "static"
    throw Error "listElement cannot be position static"

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
        throw Error "Bad width child: #{child}, width: #{childRect.width}"

      column = 0
      for i in [0...numColumns]
        if columnHeights[i] < columnHeights[column]
          column = i

      leftMargin = (totalWidth % columnWidth) / 2
      columnOffset = column * columnWidth

      childPositions.set child, {
        x: leftMargin + columnOffset
        y: columnHeights[column]
      }

      columnHeights[column] += childRect.height

    childPositions.forEach ({x, y}, child) ->
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
    try
      doLayout()
    catch _error
      for i in [0...listElement.children.length]
        listElement.children[i].style.position = ""

  # TODO: redo this on child added or removed
  listElement.layoutNewChildren()

  resizeTimeout = null
  window.addEventListener "resize", () ->
    clearTimeout(resizeTimeout)
    resizeTimeout = setTimeout(doLayout, 400)

connectInfiniteList = (listElement, {footerElement, onPageAdd, getPage}) ->
  numPages = +listElement.dataset.numPages
  nextPage = 2
  hasReachedEnd = false
  isFetching = false

  footerElement.innerHTML = "<p>Loading more...</p>"

  checkAndLoadMore = () ->
    if not hasReachedEnd
      if nextPage > numPages
        footerElement.innerHTML = "<p>No more pictures.</p>"
        hasReachedEnd = true
        window.removeEventListener "scroll", checkAndLoadMore

      windowBottom = window.innerHeight
      footerTop = footerElement.getBoundingClientRect().top
      if footerTop < windowBottom and not isFetching
        # The footer is visible, load the next page
        isFetching = true
        getPage(nextPage)
          .then((pageContent) ->
            listElement.appendChild(pageContent)
            onPageAdd()
            nextPage++
            isFetching = false
          )
          .catch((error) ->
            footerElement.textContent =
              "Couldn't load the next page. #{error.message}"
          )

  checkAndLoadMore()
  window.addEventListener "scroll", checkAndLoadMore

document.addEventListener "turbolinks:load", () ->
  list = document.querySelector(".list")
  # TODO: wait until all images have their sizes
  if list != null
    connectMasonryLayout list

    connectInfiniteList(
      list,
      {
        footerElement: document.querySelector(".footer")
        onPageAdd: list.layoutNewChildren
        getPage: (page) ->
          fetch("/images.json?page=#{page}").then((response) ->
            if response.ok
              response.json().then((images) ->
                documentFragment = document.createDocumentFragment()
                template = document.querySelector("template#image-template")
                for image in images
                  instance = template.content.cloneNode(true)
                  linkElement = instance.querySelector(".image__link")
                  titleElement = instance.querySelector(".image__title")
                  imageElement = instance.querySelector(".image__img")

                  linkElement.href = "/images/#{image.id}"
                  titleElement.textContent = image.title
                  imageElement.src = image.url
                  imageElement.width = image.width
                  imageElement.height = image.height

                  documentFragment.appendChild instance

                documentFragment
              )
            else
              Promise.reject response.statusText
          )
      },
    )
