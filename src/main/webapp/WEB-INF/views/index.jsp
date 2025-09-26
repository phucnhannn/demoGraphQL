<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Demo GraphQL</title>
    <style>
        body{font-family:Arial, sans-serif;margin:20px;}
        h2{margin-top:40px;}
        table{border-collapse:collapse;width:100%;margin-top:10px;}
        th,td{border:1px solid #ccc;padding:6px;font-size:14px;}
        th{background:#f0f0f0;}
        .flex{display:flex;gap:40px;flex-wrap:wrap}
        form{border:1px solid #ddd;padding:12px;border-radius:6px;min-width:260px;background:#fafafa;}
        label{display:block;margin-top:6px;font-weight:bold;}
        input,textarea,select{width:100%;padding:4px;margin-top:2px;}
        button{margin-top:10px;padding:6px 14px;cursor:pointer;}
        .badge{background:#1976d2;color:#fff;padding:2px 6px;border-radius:4px;font-size:11px;}
        .mut-res{white-space:pre;font-size:12px;background:#222;color:#0f0;padding:6px;max-height:180px;overflow:auto;}
    </style>
</head>
<body>
<h1>Demo GraphQL + Spring Boot (AJAX)</h1>
<p>Endpoint GraphQL: <code>/graphql</code></p>

<section>
    <h2>Products (price asc)</h2>
    <button onclick="loadProductsSorted()">Reload</button>
    <table id="tblProducts">
        <thead>
        <tr>
            <th>ID</th><th>Title</th><th>Price</th><th>Qty</th><th>Category</th><th>User</th>
        </tr>
        </thead>
        <tbody></tbody>
    </table>
</section>

<section>
    <h2>Products by Category</h2>
    <select id="categoryFilter" onchange="loadProductsByCategory()"></select>
    <table id="tblProductsByCat">
        <thead>
        <tr><th>ID</th><th>Title</th><th>Price</th><th>Qty</th><th>Category</th></tr>
        </thead>
        <tbody></tbody>
    </table>
</section>

<section class="flex">
    <form onsubmit="createCategory(event)">
        <h3>Create Category</h3>
        <label>Name<input name="name" required></label>
        <label>Images<input name="images"></label>
        <button type="submit">Create</button>
        <div class="mut-res" id="resCategory"></div>
    </form>

    <form onsubmit="createUser(event)">
        <h3>Create User</h3>
        <label>Fullname<input name="fullname" required></label>
        <label>Email<input name="email" required></label>
        <label>Password<input name="password" required type="password"></label>
        <label>Phone<input name="phone"></label>
        <button type="submit">Create</button>
        <div class="mut-res" id="resUser"></div>
    </form>

    <form onsubmit="createProduct(event)">
        <h3>Create Product</h3>
        <label>Title<input name="title" required></label>
        <label>Quantity<input name="quantity" type="number" value="1"></label>
        <label>Description<textarea name="desc"></textarea></label>
        <label>Price<input name="price" type="number" step="0.01" required></label>
        <label>User<select name="userId" id="userSelect"></select></label>
        <label>Category<select name="categoryId" id="categorySelect"></select></label>
        <button type="submit">Create</button>
        <div class="mut-res" id="resProduct"></div>
    </form>
</section>

<script>
const GQL_URL = '/graphql';

async function gql(query, variables={}) {
    const res = await fetch(GQL_URL, {
        method: 'POST',
        headers: {'Content-Type':'application/json'},
        body: JSON.stringify({query, variables})
    });
    return res.json();
}

async function loadProductsSorted(){
    const q = `query { productsSortedByPrice { id title price quantity category {id name} user {id fullname} } }`;
    const data = await gql(q);
    const tbody = document.querySelector('#tblProducts tbody');
    tbody.innerHTML = '';
    (data.data?.productsSortedByPrice||[]).forEach(p=>{
        const tr=document.createElement('tr');
        tr.innerHTML = `<td>${p.id}</td><td>${p.title}</td><td>${p.price}</td><td>${p.quantity??''}</td><td>${p.category? p.category.name:''}</td><td>${p.user? p.user.fullname:''}</td>`;
        tbody.appendChild(tr);
    });
}

async function loadCategories(){
    const q = `query { categories { id name } }`;
    const data = await gql(q);
    const cats = data.data?.categories||[];
    const sel1 = document.getElementById('categoryFilter');
    const sel2 = document.getElementById('categorySelect');
    sel1.innerHTML = '<option value="">--Chọn--</option>';
    sel2.innerHTML = '<option value="">--None--</option>';
    cats.forEach(c=>{
        const o=document.createElement('option');o.value=c.id;o.textContent=c.name;sel1.appendChild(o.cloneNode(true));sel2.appendChild(o);
    });
}

async function loadUsers(){
    const q = `query { users { id fullname } }`;
    const data = await gql(q);
    const users = data.data?.users||[];
    const sel = document.getElementById('userSelect');
    sel.innerHTML = '<option value="">--None--</option>';
    users.forEach(u=>{const o=document.createElement('option');o.value=u.id;o.textContent=u.fullname;sel.appendChild(o);});
}

async function loadProductsByCategory(){
    const id = document.getElementById('categoryFilter').value;
    if(!id){document.querySelector('#tblProductsByCat tbody').innerHTML='';return;}
    const q = `query($cid: ID!){ productsByCategory(categoryId:$cid){ id title price quantity category {id name} } }`;
    const data = await gql(q,{cid:id});
    const tbody = document.querySelector('#tblProductsByCat tbody');
    tbody.innerHTML='';
    (data.data?.productsByCategory||[]).forEach(p=>{
        const tr=document.createElement('tr');
        tr.innerHTML=`<td>${p.id}</td><td>${p.title}</td><td>${p.price}</td><td>${p.quantity??''}</td><td>${p.category? p.category.name:''}</td>`;
        tbody.appendChild(tr);
    });
}

async function createCategory(e){
    e.preventDefault();
    const f=e.target;
    const q=`mutation($in:CategoryInput!){ createCategory(input:$in){ id name } }`;
    const resp=await gql(q,{in:{name:f.name.value, images:f.images.value}});
    document.getElementById('resCategory').textContent=JSON.stringify(resp,null,2);
    await loadCategories();
    f.reset();
}

async function createUser(e){
    e.preventDefault();
    const f=e.target;
    const q=`mutation($in:UserInput!){ createUser(input:$in){ id fullname } }`;
    const resp=await gql(q,{in:{fullname:f.fullname.value,email:f.email.value,password:f.password.value,phone:f.phone.value}});
    document.getElementById('resUser').textContent=JSON.stringify(resp,null,2);
    await loadUsers();
    f.reset();
}

async function createProduct(e){
    e.preventDefault();
    const f=e.target;
    const vars={title:f.title.value,quantity:parseInt(f.quantity.value||'0'),desc:f.desc.value,price:parseFloat(f.price.value),userId:f.userId.value||null,categoryId:f.categoryId.value||null};
    if(!vars.userId) delete vars.userId; if(!vars.categoryId) delete vars.categoryId;
    const q=`mutation($in:ProductInput!){ createProduct(input:$in){ id title price } }`;
    const resp=await gql(q,{in:vars});
    document.getElementById('resProduct').textContent=JSON.stringify(resp,null,2);
    await loadProductsSorted();
    if(vars.categoryId){
        document.getElementById('categoryFilter').value=vars.categoryId;
        await loadProductsByCategory();
    }
    f.reset();
}

// init
(async ()=>{
    await Promise.all([loadCategories(), loadUsers()]);
    await loadProductsSorted();
})();
</script>
</body>
</html>