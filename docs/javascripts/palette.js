(function () {
  const key = "palette";

  function applyPalette(palette) {
    document.body.setAttribute("data-palette", palette);
    localStorage.setItem(key, palette);
  }

  function createSelector(saved) {
    if (document.getElementById("palette-selector")) return;

    const select = document.createElement("select");
    select.id = "palette-selector";
    select.style.marginLeft = "1rem";
    select.style.padding = "0.25rem";
    select.style.borderRadius = "5px";
    select.style.background = "inherit";
    select.style.color = "inherit";
    select.style.fontSize = "0.9rem";

    ["dark", "light", "sepia"].forEach(opt => {
      const option = document.createElement("option");
      option.value = opt;
      option.textContent = opt.charAt(0).toUpperCase() + opt.slice(1);
      if (opt === saved) option.selected = true;
      select.appendChild(option);
    });

    select.addEventListener("change", e => applyPalette(e.target.value));
    return select;
  }

  function insertSelector() {
    const header = document.querySelector(".md-header__inner");
    if (!header) return false;

    const saved = localStorage.getItem(key) || "dark";
    applyPalette(saved);

    const select = createSelector(saved);
    if (select) header.appendChild(select);

    return true;
  }

  const interval = setInterval(() => {
    if (insertSelector()) clearInterval(interval);
  }, 200);

  setTimeout(() => clearInterval(interval), 10000);
})();
