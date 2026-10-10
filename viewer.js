document.addEventListener("DOMContentLoaded", () => {
  const list = document.querySelector("body > ul");
  if (!list) return;

  const images = Array.from(list.children).filter((item) => item.tagName === "LI");
  if (images.length === 0) return;

  const navigation = document.createElement("nav");
  navigation.className = "image-navigation";
  navigation.setAttribute("aria-label", "Image navigation");

  const previous = document.createElement("button");
  previous.type = "button";
  previous.textContent = "← Previous image";

  const position = document.createElement("span");
  position.setAttribute("aria-live", "polite");

  const next = document.createElement("button");
  next.type = "button";
  next.textContent = "Next image →";

  navigation.append(previous, position, next);
  list.before(navigation);

  images.forEach((item, index) => {
    const grab = item.querySelector(".grab");
    if (grab) grab.dataset.imageNumber = index + 1;
  });

  let current = 0;
  function show(index, readText = false) {
    current = index;
    images.forEach((item, imageIndex) => {
      item.hidden = imageIndex !== current;
    });
    position.textContent = `Image ${current + 1} of ${images.length}`;
    previous.disabled = current === 0;
    next.disabled = current === images.length - 1;

    if (readText && window.speechSynthesis && window.SpeechSynthesisUtterance) {
      window.speechSynthesis.cancel();
      const text = images[current].querySelector(".subtitle span")?.textContent.trim();
      if (text) {
        window.speechSynthesis.speak(new window.SpeechSynthesisUtterance(text));
      }
    }
  }

  previous.addEventListener("click", () => show(current - 1, true));
  next.addEventListener("click", () => show(current + 1, true));
  document.addEventListener("keydown", (event) => {
    if (event.altKey || event.ctrlKey || event.metaKey) return;
    if (event.target.closest?.("input, textarea, select, [contenteditable]")) return;

    if (event.key === "ArrowLeft" && current > 0) {
      event.preventDefault();
      show(current - 1, true);
    } else if (event.key === "ArrowRight" && current < images.length - 1) {
      event.preventDefault();
      show(current + 1, true);
    }
  });
  show(0);
});
