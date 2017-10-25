document.oncontextmenu = function () {
    return false;
} //Anular el Boton Der del Mouse 

var controlprecionado = 0;
var altprecionado = 0;
var shiftprecionado = 0;
function desactivarCrlAlt(teclaactual) {
    var desactivar = false;
    if (controlprecionado === 17) {//ctrl
        if (teclaactual === 78 || teclaactual === 85) {
            //alert("Ctrl+N y Ctrl+U deshabilitado");
            desactivar = true;
        }
        if (teclaactual === 82) {
            //alert("Ctrl+R deshabilitado");
            desactivar = true;
        }
        if (teclaactual === 116) {
            //alert("Ctrl+F5 deshabilitado");
            desactivar = true;
        }
        if (teclaactual === 114) {
            //alert("Ctrl+F3 deshabilitado");
            desactivar = true;
        }
        if (teclaactual === 67) {
            //alert("Ctrl+F3 deshabilitado");
            desactivar = true;
        }
        if (teclaactual === 86) {
            //alert("Ctrl+F3 deshabilitado");
            desactivar = true;
        }
    }

    if (altprecionado == 18) {//Alt +
        if (teclaactual == 37) {
            //alert("Alt+ [<-] deshabilitado");
            desactivar = true;
        }
        if (teclaactual == 39) {
            //alert("Alt+ [->] deshabilitado");
            desactivar = true;
        }
    }

    //Shift +
    if (altprecionado == 16) {
        if (teclaactual == 45) {//insert
            desactivar = true;
        }
        if (teclaactual == 46) {//delete
            desactivar = true;
        }
    }

    if (teclaactual == 16) {
        shiftprecionado = teclaactual;
    }
    if (teclaactual == 17) {
        controlprecionado = teclaactual;
    }
    if (teclaactual == 18) {
        altprecionado = teclaactual;
    }
    return desactivar;
}

document.onkeyup = function () {
    if (window.event && window.event.keyCode === 16) {
        shiftprecionado = 0;
    }
    if (window.event && window.event.keyCode === 17) {
        controlprecionado = 0;
    }
    if (window.event && window.event.keyCode === 18) {
        altprecionado = 0;
    }
}

document.onkeydown = function () {
    if (window.event &&
            desactivarCrlAlt(window.event.keyCode)) {
        return false;
    }

    if (window.event && (window.event.keyCode == 122 || //122->f11
            window.event.keyCode == 116 || //116->f5
            window.event.keyCode == 114 || //114->f3
            window.event.keyCode == 117)) {//117->f6

        window.event.keyCode = 505;
    }

    if (window.event.keyCode == 505) {
        return false;
    }

    if (window.event.shiftKey) {
        return false;
    }

    if (window.event && (window.event.keyCode == 8)) {//backspace
        valor = document.activeElement.value;
        if (valor == undefined) {
            //Evita Back en página.
            return false;
        } else {
            if (document.activeElement.getAttribute('type')
                    == 'select-one')
            {
                return false;
            } //Evita Back en select.
            if (document.activeElement.getAttribute('type')
                    == 'button')
            {
                return false;
            } //Evita Back en button.
            if (document.activeElement.getAttribute('type')
                    == 'radio')
            {
                return false;
            } //Evita Back en radio.
            if (document.activeElement.getAttribute('type')
                    == 'checkbox')
            {
                return false;
            } //Evita Back en checkbox.
            if (document.activeElement.getAttribute('type')
                    == 'file')
            {
                return false;
            } //Evita Back en file.
            if (document.activeElement.getAttribute('type')
                    == 'reset')
            {
                return false;
            } //Evita Back en reset.
            if (document.activeElement.getAttribute('type')
                    == 'submit')
            {
                return false;
            } //Evita Back en submit.
            else //Text, textarea o password
            {
                if (document.activeElement.value.length == 0) {
                    //No realiza el backspace(largo igual a 0).
                    return false;
                } else {
                    //Realiza el backspace.
                    document.activeElement.value.keyCode = 8;
                }
            }
        }
    }
}