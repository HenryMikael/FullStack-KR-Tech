const API_URL = 'http://127.0.0.1:5000';

let editando = false;

async function carregarProdutos() {

    const response = await fetch(`${API_URL}/products`);

    const produtos = await response.json();

    const tabela = document.getElementById('products-table');

    tabela.innerHTML = '';

    produtos.forEach(produto => {

        tabela.innerHTML += `
            <tr>
                <td>${produto.id}</td>
                <td>${produto.nome}</td>
                <td>R$ ${produto.preco}</td>
                <td>${produto.estoque}</td>
                <td>${produto.categoria}</td>
                <td>
                    <img src="${produto.imagem_url}" width="30">
                </td>
                <td>
                    <button onclick="editarProduto(${produto.id})">
                        Editar
                    </button>

                    <button onclick="deletarProduto(${produto.id})">
                        Excluir
                    </button>
                </td>
            </tr>
        `;
    });
}

async function carregarCategorias() {

    const response = await fetch(`${API_URL}/categories`);
    const categorias = await response.json();
    const select = document.getElementById('categoria');

    categorias.forEach(categoria => {

        select.innerHTML += `
            <option value="${categoria.id}">
                ${categoria.nome}
            </option>
        `;
    });
}

async function salvarProduto() {

    const id = document.getElementById('product-id').value;

    const formData = new FormData();

    formData.append(
        'nome',
        document.getElementById('nome').value
    );

    formData.append(
        'descricao',
        document.getElementById('descricao').value
    );

    formData.append(
        'preco',
        document.getElementById('preco').value
    );

    formData.append(
        'estoque',
        document.getElementById('estoque').value
    );

    formData.append(
        'categoria_id',
        document.getElementById('categoria').value
    );

    formData.append(
        'imagem_url',
        document.getElementById('imagem_url').value
    );

    if (editando) {

        await fetch(`${API_URL}/products/${id}`, {
            method: 'PUT',
            body: formData
        });

    } else {

        formData.append('user_id', 1);

        await fetch(`${API_URL}/products`, {
            method: 'POST',
            body: formData
        });
    }

    limparFormulario();

    carregarProdutos();
}

async function editarProduto(id) {

    const response = await fetch(
        `${API_URL}/products/${id}`
    );

    const produto = await response.json();

    document.getElementById('product-id').value = produto.id;
    document.getElementById('nome').value = produto.nome;
    document.getElementById('descricao').value = produto.descricao;
    document.getElementById('preco').value = produto.preco;
    document.getElementById('estoque').value = produto.estoque;
    document.getElementById('categoria').value = produto.categoria_id;
    document.getElementById('imagem_url').value = produto.imagem_url || '';
    editando = true;
}

async function deletarProduto(id) {

    await fetch(`${API_URL}/products/${id}`, {
        method: 'DELETE'
    });

    carregarProdutos();
}

function limparFormulario() {

    document.getElementById('product-id').value = '';
    document.getElementById('nome').value = '';
    document.getElementById('descricao').value = '';
    document.getElementById('preco').value = '';
    document.getElementById('estoque').value = '';
    document.getElementById('categoria').value = '';
    editando = false;
}

carregarProdutos();

carregarCategorias();


