var Config

window.addEventListener('message', function(event) {
    var data = event.data;
    if(data.event=="openMenu"){
        syncVehicleData()
        document.body.style.display = "block";
        
    }else if(data.event=="populatePresets"){
        addSavedPresets(data.presets)
    }
    
});

function addSavedPresets(presets){
    const savedPresetsContainer = document.getElementById('savedPresets');
    savedPresetsContainer.innerHTML = "";
    const listBox = document.createElement('ul');
    listBox.classList.add('preset-list'); 
    

    const presetKeys = Object.keys(presets);

    for (let i = 0; i < presetKeys.length; i++) {
        const preset = presets[presetKeys[i]];
        const listItem = document.createElement('li');
        listItem.classList.add('preset-item');
    
        const presetName = document.createElement('span');
        presetName.textContent = preset.name;
        presetName.classList.add('preset-name');
    
        const applyButton = document.createElement('button');
        applyButton.textContent = Config.locale["apply"];
        applyButton.classList.add('apply-btn');

        applyButton.addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
                event: 'applyPreset',
                data: preset.data,
            }));
        });
    
        const deleteButton = document.createElement('button');
        deleteButton.textContent = Config.locale["delete"];
        deleteButton.classList.add('delete-btn');
        deleteButton.addEventListener('click', () => {
            listItem.remove();
            $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
                event: 'deletePreset',
                index: i,
            }));
        });
    
        listItem.appendChild(presetName);
        listItem.appendChild(applyButton);
        listItem.appendChild(deleteButton);
    
        listBox.appendChild(listItem);
    }
    
    
    savedPresetsContainer.appendChild(listBox);
}

function syncVehicleDataDelayed(){
    setTimeout(() => {
        syncVehicleData();
    }, 60);
}

const neonAnimationElements = [
    "flashNeon",
    "breathingNeon",
    "raveNeon",
    "aroundNeon",
    "ftbNeon",
    "reactiveNeon",
    "flashHeadlights",
];

const headlightAnimationElements = [
    "flashHeadlights",
];

function syncVehicleData() {
    $.post(`https://${GetParentResourceName()}/getVehicleData`, JSON.stringify({}), function(data) {
        const neonsElements = {
            left: document.getElementById('left-neon'),
            right: document.getElementById('right-neon'),
            front: document.getElementById('front-neon'),
            back: document.getElementById('back-neon'),
        };
        const neonControls = {
            front: document.getElementById('front-enable'),
            back: document.getElementById('back-enable'),
            left: document.getElementById('left-enable'),
            right: document.getElementById('right-enable'),
        };

        
        var neonColorHex = rgbToHex(data.neonColor[0], data.neonColor[1], data.neonColor[2])
        var headlightColorHex = rgbToHex(data.headlightColor[1], data.headlightColor[2], data.headlightColor[3])
        
        const overallNeonColor = document.getElementById('overall-color');
        overallNeonColor.value = neonColorHex;
        const overallHeadlightColor = document.getElementById('overall-headlight-color');
        overallHeadlightColor.value = headlightColorHex;

        const leftHeadlight = document.getElementById('left-headlight');
        const rightHeadlight = document.getElementById('right-headlight');

        leftHeadlight.style.backgroundColor = headlightColorHex;
        rightHeadlight.style.backgroundColor = headlightColorHex;

    for (let i = 0; i < Object.keys(data.neons).length; i++) {
            const neonKey = Object.keys(data.neons)[i];
            const neon = data.neons[neonKey];
            if (neon || (data.neonAnimation)) {
                neonsElements[neonKey].style.display = 'block';
                neonControls[neonKey].checked = true;
            } else {
                neonsElements[neonKey].style.display = 'none';
                neonControls[neonKey].checked = false;
            }
            neonsElements[neonKey].style.backgroundColor = neonColorHex;
        }    

        if (data.rainbowEnabled) {
            document.querySelector('[data-animation="breathingNeon"]').disabled = true
            document.querySelector('[data-animation="reactiveNeon"]').disabled = true
            document.querySelector('[data-animation="rainbow"]').style.backgroundColor = '#048aff'
        }else{
            document.querySelector('[data-animation="breathingNeon"]').disabled = false
            document.querySelector('[data-animation="reactiveNeon"]').disabled = false
            document.querySelector('[data-animation="rainbow"]').style.backgroundColor = '#444'
        }

        if (data.neonAnimation) {
            neonControls["front"].disabled = true
            neonControls["left"].disabled = true
            neonControls["right"].disabled = true
            neonControls["back"].disabled = true
            if (data.neonAnimation == "breathingNeon" || data.neonAnimation == "reactiveNeon") {
                document.querySelector('[data-animation="rainbow"]').disabled = true
            }
            document.querySelector(`[data-animation="${data.neonAnimation}"]`).style.backgroundColor = '#048aff'
        }else{
            neonControls["front"].disabled = false
            neonControls["left"].disabled = false
            neonControls["right"].disabled = false
            neonControls["back"].disabled = false
            document.querySelector('[data-animation="rainbow"]').disabled = false

            neonAnimationElements.forEach(  animationElement => {
                document.querySelector(`[data-animation="${animationElement}"]`).style.backgroundColor = '#444'
            })
        }

        if (data.rainbowEnabledHeadlights) {
            document.querySelector('[data-animation="rainbowHeadlights"]').style.backgroundColor = '#048aff'
            headlightAnimationElements.forEach(animationElement => {
                document.querySelector(`[data-animation="${animationElement}"]`).disabled = true
            })
        }else{
            document.querySelector('[data-animation="rainbowHeadlights"]').style.backgroundColor = '#444'
            headlightAnimationElements.forEach(animationElement => {
                document.querySelector(`[data-animation="${animationElement}"]`).disabled = false
            })
        }

        if (data.headlightAnimation) {
            document.querySelector('[data-animation="rainbowHeadlights"]').disabled = true
            document.querySelector(`[data-animation="${data.headlightAnimation}"]`).style.backgroundColor = '#048aff'
        }else{
            document.querySelector('[data-animation="rainbowHeadlights"]').disabled = false
            headlightAnimationElements.forEach(animationElement => {
                document.querySelector(`[data-animation="${animationElement}"]`).style.backgroundColor = '#444'
            })
        }
    });
}

$(document).keyup(function(event) {
    if (event.which == 27) {
        closeMenu()
        return
    }
});

function closeMenu(){
    $.post(`https://${GetParentResourceName()}/closeMenu`);
    document.body.style.display = "none";
}

function setLocales() {
    document.querySelectorAll('[data-locale]').forEach(element => {
        const localeKey = element.getAttribute('data-locale');
        if (Config.locale[localeKey]) {
            if (element.tagName === 'INPUT' && element.type === 'text') {
                element.placeholder = Config.locale[localeKey];
            } else {
                element.textContent = Config.locale[localeKey];
            }
        }
    });
}

document.addEventListener('DOMContentLoaded', function () {
    $.post(`https://${GetParentResourceName()}/getConfig`, JSON.stringify({}), function(data) {
        Config = data
        setLocales()
    });
    

    const neons = {
        front: document.getElementById('front-neon'),
        back: document.getElementById('back-neon'),
        left: document.getElementById('left-neon'),
        right: document.getElementById('right-neon')
    };


    const headlights = {
        left: document.getElementById('left-headlight'),
        right: document.getElementById('right-headlight')
    };


    const neonControls = {
        front: document.getElementById('front-enable'),
        back: document.getElementById('back-enable'),
        left: document.getElementById('left-enable'),
        right: document.getElementById('right-enable'),
    };

    for (let i = 0; i < Object.keys(neonControls).length; i++) {
        const side = Object.keys(neonControls)[i];
        const control = neonControls[side];
    
        control.addEventListener('change', function () {
            const neon = neons[side];
            const isEnabled = neonControls[side].checked;
        
            neon.style.display = isEnabled ? 'block' : 'none';
            $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
                event: 'toggleLight',
                side: side,
            }));

            syncVehicleDataDelayed()
        });
    }
    
    const animations = {
        rainbow: { event: 'toggleRainbow' },
        rainbowHeadlights: { event: 'toggleRainbowHeadlights' },
        flashNeon: { event: 'neonAnimation', type: 'flashNeon' },
        raveNeon: { event: 'neonAnimation', type: 'raveNeon' },
        breathingNeon: { event: 'neonAnimation', type: 'breathingNeon' },
        aroundNeon: { event: 'neonAnimation', type: 'aroundNeon' },
        ftbNeon: { event: 'neonAnimation', type: 'ftbNeon' },
        reactiveNeon: { event: 'neonAnimation', type: 'reactiveNeon' },
        flashHeadlights: { event: 'headlightAnimation', type: 'flashHeadlights' },
    };
    
    document.querySelectorAll('[data-animation]').forEach(button => {
        button.addEventListener('click', () => {
            const animationType = button.getAttribute('data-animation');
            const data = animations[animationType];

            if (data) {
                $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify(data));
                syncVehicleDataDelayed();
                neonAnimationElements.forEach(  animationElement => {
                    document.querySelector(`[data-animation="${animationElement}"]`).style.backgroundColor = '#444'
                })
                button.style.backgroundColor = '#048aff'
            }
        });
    });

    document.querySelector('[data-animation="clearHeadlights"]').addEventListener('click', () => {
        $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
            event: 'clearHeadlightColor',
        }));
        syncVehicleDataDelayed()
    });

    document.querySelector('[data-animation="toggleLight"]').addEventListener('click', () => {
        const isVisible = neons.front.style.display !== 'none';
        for (let i = 0; i < Object.keys(neons).length; i++) {
            const neonKey = Object.keys(neons)[i];
            const neon = neons[neonKey];

            neon.style.display = isVisible ? 'none' : 'block';
            neonControls[neonKey].checked = isVisible ? false : true;
        }
        

        $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
            event: 'toggleLights',
        }));
        syncVehicleDataDelayed()
    });

    const overallNeonColor = document.getElementById('overall-color');
    const overallHeadlightColor = document.getElementById('overall-headlight-color');

    overallNeonColor.addEventListener('input', function () {
        Object.keys(neons).forEach(side => {
            const neon = neons[side];

            neon.style.backgroundColor =  overallNeonColor.value;
            neon.style.display = neonControls[side].checked ? 'block' : 'none';
        });
        $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
            event: 'changeAllNeonColor',
            color: hexToRgb(overallNeonColor.value),
        }));
    });

    overallHeadlightColor.addEventListener('change', function () {
        Object.keys(headlights).forEach(side => {
            const headlight = headlights[side];
            headlight.style.backgroundColor = overallHeadlightColor.value;
        });

        $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
            event: 'changeAllHeadlightColor',
            color: hexToRgb(overallHeadlightColor.value),
        }));
    });
    
    const savePresetButton = document.getElementById('savePresetButton');
    const presetInput = document.getElementById('presetInput');
    
    savePresetButton.addEventListener('click', () => {
        const newPreset = presetInput.value.trim(); 
    
        if (newPreset) {
            $.post(`https://${GetParentResourceName()}/callback`, JSON.stringify({
                event: 'saveConfigData',
                name: newPreset,
            }));
        }
    });

    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(button => {
        button.addEventListener('click', function () {
            const target = this.dataset.target;

            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabContents.forEach(content => content.classList.remove('active'));

            this.classList.add('active');
            document.getElementById(target).classList.add('active');
        });
    });
});
4
function hexToRgb(hex) {
    hex = hex.replace(/^#/, '');
    let r = parseInt(hex.substring(0, 2), 16);
    let g = parseInt(hex.substring(2, 4), 16);
    let b = parseInt(hex.substring(4, 6), 16);

    return {
        r: r,
        g: g,
        b: b,
    };
}

function rgbToHex(r, g, b) {
    r = Math.max(0, Math.min(255, r));
    g = Math.max(0, Math.min(255, g));
    b = Math.max(0, Math.min(255, b));

    const hexR = r.toString(16).padStart(2, '0');
    const hexG = g.toString(16).padStart(2, '0');
    const hexB = b.toString(16).padStart(2, '0');

    return `#${hexR}${hexG}${hexB}`;
}
