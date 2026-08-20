(function () {
  "use strict";

  var root = document.documentElement;
  var toggle = document.querySelector(".theme-toggle");

  if (toggle) {
    toggle.addEventListener("click", function () {
      var current = root.getAttribute("data-theme");
      var isDark = current
        ? current === "dark"
        : window.matchMedia("(prefers-color-scheme: dark)").matches;
      var next = isDark ? "light" : "dark";
      root.setAttribute("data-theme", next);
      try {
        localStorage.setItem("theme", next);
      } catch (e) {}
    });
  }

  document.querySelectorAll(".highlight").forEach(function (block) {
    var code = block.querySelector("code");
    if (!code || !navigator.clipboard) return;
    var button = document.createElement("button");
    button.type = "button";
    button.className = "copy-code";
    button.textContent = "Copy";
    button.addEventListener("click", function () {
      navigator.clipboard.writeText(code.innerText).then(function () {
        button.textContent = "Copied";
        setTimeout(function () {
          button.textContent = "Copy";
        }, 1500);
      });
    });
    block.appendChild(button);
  });

  if (navigator.clipboard) {
    document.querySelectorAll(".anchor-link").forEach(function (link) {
      link.addEventListener("click", function () {
        navigator.clipboard.writeText(link.href);
        link.classList.add("copied");
        setTimeout(function () {
          link.classList.remove("copied");
        }, 1200);
      });
    });
  }

  var shareButton = document.querySelector("[data-share]");
  if (shareButton) {
    shareButton.addEventListener("click", function () {
      var data = {
        title: shareButton.getAttribute("data-title") || document.title,
        url: shareButton.getAttribute("data-url") || location.href,
      };
      if (navigator.share) {
        navigator.share(data).catch(function () {});
      } else if (navigator.clipboard) {
        navigator.clipboard.writeText(data.url).then(function () {
          var label = shareButton.textContent;
          shareButton.textContent = "Link copied";
          setTimeout(function () {
            shareButton.textContent = label;
          }, 1500);
        });
      }
    });
  }
})();
