# Algumas regras básicas

O objetivo da colaboração é fazer o modelo de Ising básico. Para isso, vamos
seguir algumas regras simples de forma a manter o programa legível para outras
pessoas.

# Sobre o programa

1. Seguir o Zen do Python. Se não sabe o que é isso é só digitar `import this` no Python.

2. O programa deve ser todo separado em funções de forma que possamos modifica-lo sem muita dificuldade. 

3. Tudo dentro do programa em inglês, desde os nomes das variáveis até comentários.

4. Toda função deve conter a seguinte descrição:  (Exemplo prático abaixo)

    - Um pequeno texto descrevendo o que a função faz.
    - Parâmetros com o tipo da variável e o que ela representa.
    - O que a função retorna.
    - As dependências da função.
    - Alguns comentários se forem necessários.

    ```python 
    '''  
      Retorna a velocidade da partícula, dada sua posição.

      Parameters:

        x : real

            Posição do objeto no eixo x.

      Returns:

        v : real

            Velocidade da partícula.

      Requires:

        tempo : function

            Função que retorna o tempo t.

      Notes:

        Nenhum comentário.
    '''
    ```  
