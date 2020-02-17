#!/bin/bash
#
#========================================================================================
# Criado por  Waldeir Monteiro - LEA (Laboratório de ELetromagnetismo Aplicado - UFPA)	=
#========================================================================================
#Versão 1.2
# Esse script mostra o cardápio do Restaurante Universitário da UFPA
# Para usá-lo faça o seguinte:
#	1. Coloque este arquivo na pasta '.scripts' em seu diretório home;
# 	(Caso a pasta não exista crie)
#	
#	2. Dê permissão de execução a este arquivo;
#
#	3. Acrescente a seguite linha no arquivo .bashrc, que fica em seu diretório home:
# 		'PATH=$PATH:~/.scripts'
# 	sem as aspas.
#	
#	4. Depois disso é só abrir um NOVO terminal, digitar "ru" sem aspas e dar enter.

#########################FUNÇÕES USADAS NO PROGRAMA##########################
#############################################################################
# Função que que baixa o menu e armazena no arquivo                         #
# $HOME/.scripts/restaurante/temp                                           #
#############################################################################

#Configure o diretório padrão onde os arquivos vão ficar
DEST_DIR="$HOME/.scripts"

# Função que que baixa o menu e armazena num arquivo  para ser lido offline           #
downloadMenu() {

wget -q 'http://ru.ufpa.br/index.php?option=com_content&view=article&id=7' -O $DEST_DIR/restaurante/index.html
if [ $? -ne 0 ]
then
	rm $DEST_DIR/restaurante/index.html
	echo Erro ao baixar o novo menu. Verifique a conexão com a internet.
	exit 2
fi
#Isolando a tabela das refeições do resto do .html#############################
sed -n '/<tbody>/,/<\/tbody>/p' $DEST_DIR/restaurante/index.html|
sed 's/<\/\?tr[^>]*>/|/g' |
sed 's/<\/td[^>]*>/+/g'|
sed 's/<[^>]*>//g'|
sed 's/-/\n/g'|
sed '/|/d'|
sed 's/^ *//g'|
sed 's/\r/\n/'|
sed '/^$/d'|
sed '/CARDÁPIO DO DIA/,//d'> $DEST_DIR/restaurante/temp
echo "THE_END" >> $DEST_DIR/restaurante/temp
}
###############################################################################

#Função que retorna o menu com o símbolo '+' marcando os lugares onde haverá 
#quebra de linhas.
retornaMenu() {
case $day in

	1)
		sed -n '/SEGUNDA/,/TERÇA/p' $DEST_DIR/restaurante/temp |sed '/TERÇA/d'
		;;
	2)
		sed -n '/TERÇA/,/QUARTA/p' $DEST_DIR/restaurante/temp |sed '/QUARTA/d'
		;;
	3)
		sed -n '/QUARTA/,/QUINTA/p' $DEST_DIR/restaurante/temp |sed '/QUINTA/d'
		;;

	4)
		sed -n '/QUINTA/,/SEXTA/p' $DEST_DIR/restaurante/temp |sed '/SEXTA/d'
		;;

	5)
		sed -n '/SEXTA/,/THE_END/p' $DEST_DIR/restaurante/temp |sed '/THE_END/d'
		;;

	*)
		echo "O ru não funciona aos finais de semana"
		;;
esac
}

#Função para Entrar no modo gráfico#############################################
gru() {
while [ 0 -eq 0 ]
do

if [ -z $DIA ]
then
DIA=Segunda
fi

DIA=$(dialog --stdout --title 'RU' --default-item $DIA --menu 'Escolha o dia da semana' 0 0 0 Segunda '' Terça '' Quarta '' Quinta '' Sexta '')



if [ $? -eq 1 -o $? -eq 255 ]
then
	clear
	echo Tchau!
	exit 1
elif [ $? -eq 127 ]
then
	echo Para usar o modo gráfico é nescessário instalar o programa dialog.
	exit 7
fi

echo $DIA

case $DIA in
	Segunda)
		day=1
		;;
	Terça)
		day=2
		;;
	Quarta)
		day=3
		;;
	Quinta)
		day=4
		;;
	Sexta)
		day=5
		;;

	*)
		;;
esac

#dialog --title $DIA --msgbox $MENU 0 0
MENU=$(retornaMenu)
MENU=$(echo "$MENU"| sed 's/\+/\n/g')

#Essas aspas escapadas que eu coloquei no comando dialog foram por
#causa do eval. Se tirar elas o eval não fornece os parâmetros corretamente
#para o dialog. As aspas duplas em "$MENU" preservam os linefeeds da variável
eval dialog --title 'Cardápio' --msgbox \' "$MENU" \' 0 0

done
}

#Mostra a ajuda do programa################################################
Ajuda() {
echo Uso: ru [OPÇÃO]
echo Mostra o cardápio do ru da UFPA em um dia da semana.
echo -e ''
echo '  -f		força baixar o cardápio atual'
echo '  -g		entra no modo gráfico'
echo '  -h, --help	mostra esta ajuda'
echo '   K		número inteiro (2-6) que especifica o dia da semana do qual o cardápio será mostrado.'

echo Exemplos:
echo ru 2 	\#Mostra o cardápio da segunda feira
echo ru 3	\#Mostra o cardápio da terça feira
}
############################################################################

#====================#
#	INÍCIO       #
#====================#

# A linha abaixo cria o diretório 'restaurante' se ele não existir.
# É neste diretório que ficarão arquivos temporários que o script
# usa.
[ ! -e $DEST_DIR/restaurante/ ] && [ $(mkdir $DEST_DIR/restaurante/) ]

##########################VERIFICAÇÃO########################################
#Verifica se a página do ru já foi baixada alguma vez, se não, baixa o menu.#
#Verifica se o último cardápio baixado é dessa semana, caso contrário,      #
#baixa o cardápio atual.                                                    #

if  [ ! -e $DEST_DIR/restaurante/index.html ]
then
	downloadMenu
	isolarMenu

elif [ $(date +%W) -ne $(date -r $DEST_DIR/restaurante/index.html +%W 2>/dev/null) ]
then
	downloadMenu
	isolarMenu
fi

if [ ! -e $RU_TABELA -o ! -e $TABELAS ]
then
	isolarMenu
fi
#########################FIM DA VERIFICAÇÃO###############################



# Testando o número de argumentos passados ao script, se for maior 
# que 1 exibe uma mensagem de erro


if [ $# -gt 1 ]
then
	Ajuda
	exit 1
# A variável day controla o dia da semana cujo cardápio será impresso.
# Caso o número passado pelo usuário não esteja entre 1 e 7, esta variável
# será igualada ao dia da semana atual.
elif [ $1 -gt 1 -a $1 -lt 7 ] 2>/dev/null # 
then
	day=$(( $1 - 1 ))

elif [ $# -eq 0 ]
then
	day=$(date +%u)

elif [ $1 = '-f' ]
then
	downloadMenu
	isolarMenu
	exit 0
elif [ $1 = '-g' ]
then
	gru
	exit 0
elif [ $1 = '-h' -o $1 = '--help' ]
then
	Ajuda
	exit 0
else
	echo -e "Erro: Argumento '$1' inválido!\n"
	Ajuda
	exit 4

fi


#Uso esse último sed para eliminar acentos pois vou colocar esse script junto com o conky, combinado com uma fonte que não permite acentuação
#retornaMenu|sed 's/+/\n/g'|sed  'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚñÑçÇ/aAaAaAaAeEeEiIoOoOoOuUnNcC/' 

#Versão com acentos
retornaMenu|sed 's/+/\n/g'
#echo -e "\nData de hoje: $(date +%d-%m-%Y)"
#coloque isso lá no conkyrc antes do ru
#${font Antique Type:size=8}${color #993300}$stippled_hr
#${color #ccaa77}${font Poky:size=15}n${color #ccaa77}${font WW2 BlackltrAlt:size=20} Cardápio RU  $stippled_hr ${color #996633}${font Inconsolata:size=8.5}
#${exec ru}
exit 0
