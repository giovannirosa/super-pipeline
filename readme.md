# Arquitetura Trabalho 1 - Extra

Trabalho 1 da matéria de Arquitetura do primeiro semestre de 2018, Universidade Federal do Paraná - UFPR.

## Início

Existe um makefile neste diretório com os seguintes comandos disponíveis:

* make sim: compila os arquivos basic_types.vhd, reg.vhd, add32.vhd, mux2.vhd, mux3.vhd, mux4.vhd, rom32.vhd, reg32_ce.vhd, reg_bank.vhd, control_pipeline.vhd, shift_left.vhd, alu.vhd, alu_ctl.vhd, mem32.vhd, mips_pipeline.vhd, mips_tb.vhd e produz o arquivo de simulação mips.vcd
* make clean: limpa os arquivos .o e .cf

### Pré-requisitos

É necessario ter os programas ghdl e gtkwave devidamente instalados e configurados.

## Modificações

### Formato das instruções 

* R:                opcode[6 bits] rs[5 bits] rt[5 bits] rd[5 bits] shamt[5 bits] funct[6 bits]
* LW/SW/ADDI/BEQ:   opcode[6 bits] rs[5 bits] rt[5 bits] immediate[16 bits]

### Arquivos alterados

* basic_types.vhd: Foi inserida a constante ADDI.
* rom32.vhd: Foi modificado para testes.
* control_pipeline.vhd: Foi adicionado o caso de saída para ADDI.
* reg_bank.vhd: Foi alterado para suportar leitura de 2 instruções ao mesmo tempo. Sendo que a primeira sera alu/branch e a segunda de load/store.
* mips_pipeline.vhd: Foi modificado para suportar mais de uma instrução no mesmo ciclo e ADDI.
    - Estágio IF: Adição do registrador PC+8. MUX que determina se PC receberá PC+8 ou Branch.
    - Estágio ID: Operação de escrita no registrador. Foi acrescentado mais um processo para estender o valor do imediato e também mais uma unidade de controle para a instrução seguinte.
    - Estágio EX: Foi inserida mais uma ULA.
    - Estágio WB: Sua operação de escrita no registrador está sendo realizada no estágio ID.
* reg32_ce.vhd: Foi duplicada a quantidade de registradores de inicialização, para suportar 2 instruções ao mesmo tempo.

## Testando

É possível testar o programa alterando o arquivo rom32.vhd para modificar as instruções que serão processadas.

### Como testar

Verifique o arquivo basic_types.vhd para encontrar os op codes corretos. Então modifique o arquivo rom32.vhd e execute o seguinte comando:

```
make sim
```

Isso irá gerar ou sobrescrever o arquivo mips.vcd.

### Como visualizar a simulação gerada

Para facilitar a correção é recomendado a utilização do gtkwave:
```
gtkwave mips.vcd
```
**Também está incluso nesse diretório o executável mips.gtkw que já contém a janela de sinais montada no gtkwave.**

## Bibliotecas Utilizadas

* [ghdl](http://ghdl.free.fr) - GHDL is an open-source simulator for the VHDL language
* [gtkwave](http://gtkwave.sourceforge.net) - GTKWave is open source vhdl visualization software

## Autores

* **Giovanni Rosa** - [giovannirosa](https://github.com/giovannirosa)
* **Roberta Samistraro** - [rosamis](https://github.com/rosamis)

## Licença

Código aberto, qualquer um pode usar para qualquer propósito.

## Reconhecimentos

* GHDL não é produtivo nem intuitivo.
* GTKWave funciona bem mas não é intuitivo também.

## Desenvolvimento

* Tempo estimado: 22 horas.
* Ponto positivo: Entender o funcionamento de um processador superescalar em baixo nível.
* Pontos negativos: Implementar a lógica em VHDL, testar usando gtkwave e lidar com processamento em baixo nível. Também não conseguimos instalar o ghdl em nossas máquinas pessoais, tendo que utilizar ssh para compilação correta.
* Sugestões: Dar uma aula prática e objetiva sobre a linguagem VHDL e disponibilizar mais aulas de laboratório para o desenvolvimento do projeto. Dar mais aulas de superescalar afim de aprofundar o conceito.

## Testes

### Explicação do Hazard e Forward

Pelo fato de o objetivo do projeto não ser o desenvolvimento das unidades de adiantamento e unidade de detecção de riscos, quando tiver algum conflito entre instruções é necessário colocar estágios nop em rom32.vhd até que não haja mais dependencia.

### Limitações encontradas no projeto [Bugs]

Não foram encontrados bugs nos testes que fizemos, entretanto não deu tempo de realizar muitos.