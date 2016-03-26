# ru_bash
Mais um script para baixar o cardápio do ru da ufpa e mostrá-lo em sua linha de comando



# Para usá-lo faça o seguinte:
1. Coloque este arquivo na pasta '.scripts' em seu diretório home;
(Caso a pasta não exista crie)

2. Dê permissão de execução a este arquivo;

3. Acrescente a seguite linha no arquivo .bashrc, que fica em seu diretório home:

```
PATH=$PATH:~/.scripts
```

4. Depois disso é só abrir um NOVO terminal, digitar "ru" sem aspas e dar enter.

#Como funciona

Quando você roda o comando 'ru', o script verifica se há algum cardápio no computador ou se o cardápio existente é da semana atual, caso negativo em qualquer um dos casos, ele baixa o cardápio da semana inteira e armazena-o no arquivo 

```
$HOME/.scripts/restaurante/temp
```

e a seguir exibe qual o menu do dia.

Se o comando for rodado novamente na mesma semana o script não precisa mais baixar o cardápio, ele lê tudo direto do arquivo 

```
$HOME/.scripts/restaurante/temp
```

por isso podemos usá-lo offline. 


