const HOSTS = {
  GITHUB: 'github.com',
  GOOGLE_MEET: 'meet.google.com',
  GOOGLE_CLOUD_CONSOLE: 'console.cloud.google.com',
  GOOGLE_PHOTOS: 'photos.google.com',
}

function fixLinks() {
  document.querySelectorAll('a').forEach(function(a) {
    a.href = a.href.replace(/\/files(\/[^\?]*)?$/, '/files?w=1')
  })
}

function loadMoreInPrs() {
  const interval = setInterval(() => {
    const loadMoreButton = Array.from(document.querySelectorAll('button')).find(e => e.innerText.includes('hidden item'))

    if (!loadMoreButton) {
      clearInterval(interval)
      return
    }
    loadMoreButton.click()
  }, 1000)
}

fixLinks()
window.addEventListener('turbo:render', fixLinks)
window.addEventListener('turbo:frame-render', fixLinks)

const addSearchParam = (key, value) => {
  const searchParams = new URLSearchParams(window.location.search)
  if (searchParams.has(key)) {
    return
  }

  searchParams.set(key, value)
  window.location.search = searchParams.toString()
}

if (window.location.host === HOSTS.GITHUB) {
  if (window.location.pathname.match(/^\/pull\/\d+\/files/)) {
    addSearchParam('w', 1)
  }
  if (window.location.pathname.match(/\/pull\/\d+$/)) {
    loadMoreInPrs()
  }
}

if (window.location.host === HOSTS.GOOGLE_MEET) {
  addSearchParam('authuser', 1)
}

if (window.location.host === HOSTS.GOOGLE_CLOUD_CONSOLE) {
  addSearchParam('authuser', 1)
}

if (window.location.host === HOSTS.GOOGLE_PHOTOS && !window.location.pathname.startsWith('/u/')) {
  addSearchParam('authuser', 2)
}
