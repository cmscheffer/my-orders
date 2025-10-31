# 🔍 Debug dos Dropdowns - Testes no Console

## 1️⃣ Abra o Console do Navegador

Pressione `F12` e vá para a aba **Console**.

## 2️⃣ Verifique se as bibliotecas estão carregadas

Cole e execute cada linha:

```javascript
console.log("jQuery:", typeof $, $)
console.log("Popper:", typeof Popper, Popper)
console.log("Bootstrap:", typeof bootstrap, bootstrap)
```

**Resultado esperado**: Todos devem mostrar `object` ou `function` e exibir o objeto/função.

## 3️⃣ Verifique quantos dropdowns existem na página

```javascript
const dropdownElements = document.querySelectorAll('[data-bs-toggle="dropdown"]')
console.log("Dropdowns encontrados:", dropdownElements.length)
console.log("Elementos:", dropdownElements)
```

**Resultado esperado**: Deve mostrar `2` (menu Configurações + menu Usuário).

## 4️⃣ Tente inicializar os dropdowns manualmente

```javascript
const dropdownElementList = document.querySelectorAll('[data-bs-toggle="dropdown"]')
const dropdownList = [...dropdownElementList].map(dropdownToggleEl => {
  const dropdown = new bootstrap.Dropdown(dropdownToggleEl)
  console.log("Dropdown criado:", dropdown)
  return dropdown
})
console.log("Total de dropdowns inicializados:", dropdownList.length)
```

**Resultado esperado**: Deve criar 2 dropdowns e mostrar os objetos.

## 5️⃣ Teste clicar em um dropdown manualmente

Depois de executar o passo 4, tente clicar nos menus. **Eles funcionam agora?**

## 6️⃣ Se funcionou após passo 4, o problema é a inicialização

Se os dropdowns funcionaram após o passo 4, significa que o Bootstrap não está inicializando automaticamente. Vou adicionar inicialização manual no código.

## 7️⃣ Verifique eventos Turbo

```javascript
// Verificar se Turbo está ativo
console.log("Turbo:", typeof Turbo)

// Adicionar listener para ver quando Turbo carrega a página
document.addEventListener('turbo:load', () => {
  console.log("🔄 Turbo:load disparado!")
})

document.addEventListener('DOMContentLoaded', () => {
  console.log("📄 DOMContentLoaded disparado!")
})
```

Recarregue a página (`F5`) e veja quais eventos disparam.

## 8️⃣ Inspecionar o elemento dropdown

1. Clique com botão direito no menu "Configurações"
2. Escolha **Inspecionar**
3. Cole no console:

```javascript
const configMenu = document.querySelector('.nav-item.dropdown .dropdown-toggle')
console.log("Elemento do menu:", configMenu)
console.log("Data-bs-toggle:", configMenu.getAttribute('data-bs-toggle'))
console.log("Próximo elemento (dropdown-menu):", configMenu.nextElementSibling)
```

**Me envie os resultados desses testes!** Isso vai me ajudar a identificar exatamente onde está o problema. 🔍
