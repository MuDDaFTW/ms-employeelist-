let isVisible = false;
let isEditMode = false;
let mySourceId = -1;

let savedSettings = JSON.parse(localStorage.getItem("ms-elist-settings")) || {
    opacity: 1.0,
    scale: 1.0,
    top: "100px",
    left: "auto",
    right: "50px" 
};

$(document).ready(function() {
    applySettings();

    // Draggable on Wrapper (Moves everything together)
    $("#ui-wrapper").draggable({ 
        handle: ".header",
        stop: function(event, ui) {
            savedSettings.top = ui.position.top + "px";
            savedSettings.left = ui.position.left + "px";
            savedSettings.right = "auto"; 
            saveSettings();
        }
    });

    // Opacity Logic
    $("#opacity-slider").on("input change", function() {
        let val = $(this).val();
        $(".container").css("opacity", val);
        savedSettings.opacity = val;
        saveSettings();
    });

    // Scale Logic (Simple: Scale the Wrapper)
    // Works with Mouse Drag AND Arrow Keys (when focused)
    $("#scale-slider").on("input change", function() {
        let val = $(this).val();
        $("#ui-wrapper").css("transform", `scale(${val})`);
        savedSettings.scale = val;
        saveSettings();
    });

    $("#confirm-btn").click(function() {
        setHudMode();
        $.post('https://ms-employeelist/confirmSettings', JSON.stringify({}));
    });

    window.addEventListener('message', function(event) {
        let data = event.data;

        if (data.action === "openEdit") {
            $("#app").fadeIn(200);
            setEditMode();
            isVisible = true;
            // Set slider values to match saved settings
            $("#opacity-slider").val(savedSettings.opacity);
            $("#scale-slider").val(savedSettings.scale);
        } 
        else if (data.action === "close") {
            $("#app").fadeOut(200);
            isVisible = false;
        }
        else if (data.action === "updateList") {
            mySourceId = data.mySource;
            updateTable(data.employees, data.mySource, data.jobLabel);
            updateTime();
        }
    });

    $(document).keyup(function(e) {
        if (e.key === "Escape" && isVisible && isEditMode) {
            $.post('https://ms-employeelist/close', JSON.stringify({}));
        }
    });
});

function saveSettings() {
    localStorage.setItem("ms-elist-settings", JSON.stringify(savedSettings));
}

function applySettings() {
    $(".container").css("opacity", savedSettings.opacity);
    $("#ui-wrapper").css("transform", `scale(${savedSettings.scale})`);
    
    $("#ui-wrapper").css({
        top: savedSettings.top,
        left: savedSettings.left,
        right: savedSettings.right
    });
}

function setEditMode() {
    isEditMode = true;
    $("#settings-panel").show();
    $(".header").css("cursor", "grab");
    $(".edit-input").prop("disabled", false);
    $("#ui-wrapper").draggable("enable");
}

function setHudMode() {
    isEditMode = false;
    $("#settings-panel").fadeOut(200);
    $(".edit-input").prop("disabled", true);
    $("#ui-wrapper").draggable("disable");
}

function setStatus(statusType) {
    $(".st-btn").removeClass("active-selected break-selected");
    if (statusType === 'active') {
        $("#btn-active").addClass("active-selected");
    } else {
        $("#btn-break").addClass("break-selected");
    }
    $.post('https://ms-employeelist/updateSelf', JSON.stringify({
        type: 'status',
        value: statusType
    }));
}

function updateTable(employees, mySource, jobLabel) {
    if ($(document.activeElement).is("input")) return; 

    $("#job-name").text(jobLabel.toUpperCase());
    let listContainer = $("#employee-list");
    listContainer.empty();

    employees.sort((a, b) => parseInt(a.callsign) - parseInt(b.callsign));

    employees.forEach(emp => {
        let isMe = (emp.source === mySource);
        
        if (isMe && isEditMode) {
            $(".st-btn").removeClass("active-selected break-selected");
            if (emp.status === 'afk') {
                $("#btn-break").addClass("break-selected");
            } else {
                $("#btn-active").addClass("active-selected");
            }
        }

        let statusHtml = getStatusHtml(emp.status);
        let callsignContent, nameContent;

        if (isMe) {
            let disabledAttr = isEditMode ? "" : "disabled";
            callsignContent = `<input class="edit-input" ${disabledAttr} data-type="callsign" value="${emp.callsign}" onblur="updateData(this)" onkeydown="checkEnter(event, this)">`;
            nameContent = `<input class="edit-input" ${disabledAttr} data-type="name" value="${emp.name}" onblur="updateData(this)" onkeydown="checkEnter(event, this)">`;
        } else {
            callsignContent = emp.callsign;
            nameContent = emp.name;
        }

        let html = `
            <div class="row ${isMe ? 'is-me' : ''}">
                <div class="col col-callsign">${callsignContent}</div>
                <div class="col col-name">${nameContent}</div>
                <div class="col col-radio">${emp.radio}</div>
                <div class="col col-status">${statusHtml}</div>
            </div>
        `;
        listContainer.append(html);
    });
}

function getStatusHtml(status) {
    if (status === 'on_duty') return `<span class="status-badge" style="color:var(--green)"><span class="dot green-dot"></span>ON DUTY</span>`;
    if (status === 'off_duty') return `<span class="status-badge" style="color:var(--red)"><span class="dot red-dot"></span>OFF DUTY</span>`;
    if (status === 'afk') return `<span class="status-badge" style="color:var(--yellow)"><span class="dot yellow-dot"></span>BREAK</span>`;
    return 'Unknown';
}

function checkEnter(event, input) {
    if (event.key === "Enter") input.blur();
}

function updateData(input) {
    let type = $(input).data('type');
    let value = $(input).val();
    $.post('https://ms-employeelist/updateSelf', JSON.stringify({ type: type, value: value }));
}

function updateTime() {
    let date = new Date();
    $("#time").text(date.toLocaleTimeString());
}