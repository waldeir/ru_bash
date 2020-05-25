# ru_bash
Um script para baixar o cardápio do ru da ufpa e mostrá-lo em sua linha de comando offline.

![](ru.gif)

# Para usá-lo faça o seguinte:
1. Coloque o arquivo 'ru' na pasta '.scripts' em seu diretório home;
(Caso a pasta não exista crie)

2. Dê permissão de execução a este arquivo;

3. Acrescente a seguinte linha no arquivo '.bashrc', que fica em seu diretório home:

```shell
PATH=$PATH:~/.scripts
```
4. Depois disso é só abrir um NOVO terminal, digitar 'ru' sem aspas e teclar enter;

5. Para ver mais opções use o comando :
```shell
$ ru -h
```

# Como funciona

Quando você usa o comando 'ru', o script verifica se há algum cardápio no computador, se sim ele verifica se o cardápio existente é da semana atual, caso contrário, ele baixa o menu da semana inteira e armazena-o no arquivo:

```shell
$XDG_DATA_HOME/ru_bash/ruTabela.txt
```

e a seguir exibe qual o menu do dia.

Se o comando for rodado novamente na mesma semana o script não precisa mais baixar o cardápio, ele lê tudo direto do arquivo 

```shell
$XDG_DATA_HOME/ru_bash/ruTabela.txt
```

por isso podemos usá-lo offline. 

OBS: é possível modificar o diretório onde os arquivos serão instalados por meio da variável "DEST_DIR", dentro do script.

# Modo Gráfico

Criado para mostrar os menus da semana de forma organizada, esse modo só é acessível se você tiver o programa "dialog" instalado.

O modo gráfico é ativado com o seguinte comando:

```shell
$ ru -g
```


