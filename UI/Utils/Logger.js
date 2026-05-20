// .pragma library

// function separador() {
//     return "────────────────────────────────────────"
// }

// function log(titulo, mensaje, valor) {
//     console.log("")
//     console.log(separador())
//     console.log("[" + titulo + "] " + mensaje)

//     if (valor !== undefined) {
//         if (typeof valor === "object") {
//             console.log(JSON.stringify(valor))
//         } else {
//             console.log(valor)
//         }
//     }

//     console.log(separador())
//     console.log("")
// }

// function separador() {
//     return "────────────────────────────────────────"
// }

// function log(titulo, mensaje, valor) {
//     console.log(separador())
//     console.log("[" + titulo + "] " + mensaje)

//     if (valor !== undefined) {
//         if (typeof valor === "object") {
//             console.log(JSON.stringify(valor))
//         } else {
//             console.log(valor)
//         }
//     }

//     console.log(separador())
// }

function separador() {
    return "────────────────────────────────────────"
}

function linea() {
    console.log(separador())
}

function textoValor(valor) {
    if (valor === undefined) {
        return ""
    }

    if (typeof valor === "object") {
        return JSON.stringify(valor)
    }

    return valor
}

function simple(titulo, mensaje, valor) {
    if (valor !== undefined) {
        console.log("[" + titulo + "] " + mensaje + " → " + textoValor(valor))
    } else {
        console.log("[" + titulo + "] " + mensaje)
    }
}

function bloque(titulo, mensaje, valor) {
    console.log("[" + titulo + "] " + mensaje)
    if (valor !== undefined) {
        console.log(textoValor(valor))
    }
}

function log(titulo, mensaje, valor) {
    simple(titulo, mensaje, valor)
}