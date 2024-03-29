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

#########################FUNÇÕES USADAS NO PROGRAMA############################

#Configure o diretório padrão onde os arquivos vão ficar
DEST_DIR="$XDG_DATA_HOME/ru_bash"
INDEX=$DEST_DIR/index.html
TABELAS=$DEST_DIR/tabelas.txt
RU_TABELA=$DEST_DIR/ruTabela.txt

# Função que que baixa o menu e armazena num arquivo  para ser lido offline           #
downloadMenu() {

echo "Baixando Menu..."

wget -q 'https://saest.ufpa.br/ru/index.php/component/cardapio/' -O $INDEX 2> /dev/null
if [ $? -ne 0 ]
then
	rm $INDEX
	echo Erro ao baixar o novo menu. A página do restaurante pode estar indisponível, você não tem internet ou o wget não está instalado.
	exit 2
fi

# Corrigindo tag de tabela que está errado no site
sed -i "s/\t<tbody>/\t<\/tbody>/g" $INDEX
}


#############Isolando as tabelas da página do resto do html####################
isolarMenu() {
sed -n '/<tbody>/,/<\/tbody>/p'  $INDEX|
sed 's/<tbody>/Itbody/g
    s/<\/tbody>/Ftbody/g
    s/<tr[^>]*>/I|/g
    s/<\/tr[^>]*>/F|/g
    s/<td[^>]*>/I+/g
    s/<\/td[^>]*>/F+/g
    s/<[^>]*>//g
    s/\r//g
    s/^ *//g
    /^$/d' > $TABELAS
# Encontrando e isolando a tabela do ru
# Assumindo que a maior tabela é a correta 

INITS=$(sed -n '/Itbody/=' $TABELAS)
ENDS=$(sed -n '/Ftbody/=' $TABELAS)
NTABLES=$(sed -n '/Ftbody/=' $TABELAS| wc -l)

LENTemp=0

for i in $(seq 1 $NTABLES)
do
        INITT=$(echo $INITS|cut -d' ' -f$i)
        ENDT=$(echo $ENDS|cut -d' ' -f$i)
        LEN=$((ENDT - INITT))
        if [ $LEN -gt $LENTemp ]
        then
                LENTemp=$LEN
                RUTableIN=$INITT
                RUTableEND=$ENDT
        fi
done

# Eliminando tabs do texto antes de salvar a tabela
sed -n "$RUTableIN,$RUTableEND p" $TABELAS |sed "s/\t//g"> $RU_TABELA
}

###############################################################################

# Função que retorna o menu do dia

retornaMenu() {
case $day in

	1)
		L=1
		imprimeMenu
		;;
	2)
		L=2
		imprimeMenu
		;;
	3)
		L=3
		imprimeMenu
		;;

	4)
		L=4
		imprimeMenu
		;;

	5)
		L=5
		imprimeMenu
		;;

	*)
		echo "O ru não funciona aos finais de semana"
		;;
esac
}

# Imprime o cardápio conforme o dia da semana detectado em retornaMenu()
imprimeMenu() {

LINESI=(`sed -n '/I|/=' $RU_TABELA`)
LINESF=(`sed -n '/F|/=' $RU_TABELA`)

NLINES=${#LINES[*]}

MENUDODIA=`sed -n "${LINESI[$L]},${LINESF[$L]} p" $RU_TABELA`

COLUNASI=(`echo "${MENUDODIA}"|sed -n '/I+/='`)
COLUNASF=(`echo "${MENUDODIA}"|sed -n '/F+/='`)



CABECALHO=(DIA: ALMOÇO: JANTAR:)
for C in `seq 0 2`
do
    if [ $BOLD = 'NOBOLD' ]
    then
        echo -e "\n${CABECALHO[$C]}\n"
    else
        echo -e "\n\033[1m${CABECALHO[$C]}\033[0m"
    fi
    echo "${MENUDODIA}"|
    sed -n "${COLUNASI[$C]},${COLUNASF[$C]} p"|
    sed 's/\(I+\|F+\)//g' |
    sed '/^$/d'
done


}

######################Função para Entrar no modo gráfico#######################
gru() {
while [ 0 -eq 0 ]
do

if [ -z $DIA ]
then
DIA=Segunda
fi

DIA=$(dialog --stdout --cancel-label Sair --title 'RU' --default-item $DIA --menu 'Escolha o dia da semana' 0 0 0 Segunda '' Terça '' Quarta '' Quinta '' Sexta '')



if [ $? -eq 1 -o $? -eq 255 ]
then
	clear
	exit 0
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

#####################Mostra a ajuda do programa################################
Ajuda() {
echo Uso: $(basename $0) [Opções][-d dia] 
echo -e ''
echo Mostra o cardápio do ru da UFPA em um dia da semana.
echo -e ''
echo '  -f		força baixar o cardápio atual'
echo '  -g		entra no modo gráfico'
echo '  -h, --help	mostra esta ajuda'
echo '  -d dia    	dia semana do qual o cardápio será mostrado'
echo '  -b		desativa a impressão em negrito para o cabeçalho'
echo -e ''
echo Argumentos para -d
echo ' 2 | seg		Segunda'
echo ' 3 | ter		Teça'
echo ' 4 | qua		Quarta'
echo ' 5 | qui		Quinta'
echo ' 6 | sex		Sexta'

echo -e ''
echo Exemplos:
echo ' ru -d 2 	#Mostra o cardápio da segunda feira'
echo ' ru -d 3	#Mostra o cardápio da terça feira'
echo ' ru -d seg 	#Mostra o cardápio da segunda feira'
}
##############################FIM DAS FUNÇÕES##################################


#=============================================================================#
#                                 INÍCIO                                      #
#=============================================================================#



# A linha abaixo cria o diretório 'restaurante' se ele não existir.
# É neste diretório que ficarão arquivos temporários que o script
# usa.
[ ! -e $DEST_DIR ] && [ $(mkdir -p $DEST_DIR) ]

############################VERIFICAÇÃO########################################
#Verifica se a página do ru já foi baixada alguma vez, se não, baixa o menu.  #
#Verifica se o último cardápio baixado é dessa semana, caso contrário,        #
#baixa o cardápio atual.                                                      #

if  [ ! -e $INDEX ]
then
	downloadMenu
	isolarMenu

elif [ $(date +%W) -ne $(date -r $INDEX +%W 2>/dev/null) ]
then
	downloadMenu
	isolarMenu
fi

if [ ! -e $RU_TABELA -o ! -e $TABELAS ]
then
	isolarMenu
fi
###########################FIM DA VERIFICAÇÃO##################################

BOLD='YESBOLD' # Faz o cabeçalho ficar em negrito


# Se o script for chamado com um argumento  ao invés de uma opção, 
# imprima a ajuda.
str=$1
if [[  ${str::1} != - && ! -z $str ]]
then
	Ajuda
	exit 0
fi

# Predefinindo a variável $day para o dia da semana atual.
if [ -z $day ] 
then
	day=$(date +%u)
fi


# A interpretação dos argumentos do comando é feita com o getopts

while getopts ":gbfhd:" opt; do
	case "${opt}" in
		d)
			case "${OPTARG}" in
				2|seg)
					day=1
					;;
				3|ter)
					day=2
					;;
				4|qua)
					day=3
					;;
				5|qui)
					day=4
					;;
				6|sex)
					day=5
					;;
				*)
					echo "Argumento '$OPTARG' inválido para opção -$opt" 1>&2
					exit 6
					;;
			esac
					

			;;
		b)
			BOLD=NOBOLD
			;;
			
		f)
			downloadMenu
			isolarMenu
			;;
		g)
			BOLD=NOBOLD # precisa desbilitar o negrito para imprimir corretamenteos caracteres.

			gru
			;;

		:)
			echo "Opção inválida: -$OPTARG requer um argumento" 1>&2
			exit 3
			;;
		\?)
			echo "Opção inválida: -$OPTARG" 1>&2
			exit 4
			;;
		h)
			Ajuda
			exit 0
			;;
		*)
			Ajuda
			exit 5
			;;
	esac
done
shift $((OPTIND-1))

retornaMenu

exit 0
