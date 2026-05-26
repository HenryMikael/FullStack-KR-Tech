
const API_URL = 'http://127.0.0.1:5000/categories'

async function carregarCategorias() {

    const resposta = await fetch(API_URL)
    const categorias = await resposta.json()
    const tabela = document.getElementById('lista-categorias')

    tabela.innerHTML = ''

    categorias.forEach(categoria => {

        tabela.innerHTML += `
            <tr>
                <td>${categoria.id}</td>
                <td>${categoria.nome}</td>
                <td>
                    <button onclick="deletarCategoria(${categoria.id})">
                        Excluir
                    </button>
                </td>
            </tr>
        `
    })
}

async function criarCategoria() {

    const nome = document.getElementById('nome').value

    const resposta = await fetch(API_URL, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            nome
        })
    })

    const dados = await resposta.json()

    alert(dados.message || dados.error)

    document.getElementById('nome').value = ''

    carregarCategorias()
}

async function deletarCategoria(id) {

    const confirmar = confirm(
        'Deseja deletar esta categoria?'
    )

    if (!confirmar) {
        return
    }

    const resposta = await fetch(
        `${API_URL}/${id}`,
        {
            method: 'DELETE'
        }
    )

    const dados = await resposta.json()

    alert(dados.message || dados.error)

    carregarCategorias()
}

carregarCategorias()

