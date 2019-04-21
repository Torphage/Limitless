function numOfLines(element) {
    var taLineHeight = 20; // This should match the line-height in the CSS
    var taHeight = element.scrollHeight; // Get the scroll height of the textarea
    element.style.height = taHeight; // This line is optional, I included it so you can more easily count the lines in an expanded textarea
    return Math.floor(taHeight/taLineHeight);
}

function getCurrentElementChildIndex(elem) {
    let i = 1;
    while ((elem = elem.previousElementSibling) != null)++i;
    return i;
}


function saveTextarea(element) {
    const page = getCurrentElementChildIndex(element)
    if (page < 1) { return; }
    $.ajax({
        type: "POST",
        url: $('#edit-form').attr('action'),
        data: { textContent: element.value, pageInt: page },
        success: () => {
            $("#lastUpdate").html(new Date().getTime())
        }
    });
}

function removeTextarea(page) {
    console.log(page)
    $.ajax({
        type: "POST",
        url: '/delete' + $('#edit-form').attr('action').slice(5),
        data: { pageInt: page }
    })
}

function onKeyDown(element, event) {
    if (event.code === "Backspace") {
        if (element.selectionStart === 0) {
            event.preventDefault()
            if (element.nextElementSibling === null) {
                setTimeout(() => deleteTextarea(element), 10);
            } else {
                focusPrevTextarea(element);
            }
        }
    }
}

function onKeyUp(element, event) {
    const currentLine = numOfLines(element)
    if (currentLine > 60) {
        element.value = element.value.slice(0, -1)
        event.preventDefault();
        if (element.nextElementSibling === null) {
            setTimeout(() => createNewTextarea(), 10)
        } else {
            focusNextTextarea(element);
        }
    }
}

function applyEventListeners(element) {
    let timeoutId;

    element.addEventListener("input", () => {
        clearTimeout(timeoutId);

        timeoutId = setTimeout(() => saveTextarea(element), 4000)
    })

    element.addEventListener("keydown", (event) => onKeyDown(element, event))
    element.addEventListener("keyup", (event) => onKeyUp(element, event))
}

function createNewTextarea() {
    const element = document.createElement("textarea");
    element.name = "textContent";
    applyEventListeners(element);
    document.getElementById("edit-form").appendChild(element);
    element.focus();
}

function focusPrevTextarea(element) {
    const sibling = element.previousElementSibling;
    sibling.focus();
    sibling.setSelectionRange(sibling.value.length, sibling.value.length)
    element.removeEventListener("keydown", onKeyDown)
    element.removeEventListener("keyup", onKeyUp)
    applyEventListeners(sibling)
}

function focusNextTextarea(element) {
    const sibling = element.nextElementSibling;
    sibling.focus();
    element.removeEventListener("keydown", onKeyDown)
    element.removeEventListener("keyup", onKeyUp)
    applyEventListeners(sibling)
}

function deleteTextarea(element) {
    element.removeEventListener("keydown", onKeyDown)
    element.removeEventListener("keyup", onKeyUp)

    const page = getCurrentElementChildIndex(element);
    removeTextarea(page);

    const sibling = element.previousElementSibling;
    sibling.focus();
    sibling.setSelectionRange(sibling.value.length, sibling.value.length)

    element.parentElement.removeChild(element);
}

for (const element of document.getElementById("edit-form")) {
    console.log("yo")
    applyEventListeners(element);
}
