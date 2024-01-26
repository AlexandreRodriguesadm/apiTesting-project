*** Settings *** 
Resource        ../resources/api_testing.robot

*** Test Cases ***
Cenário 001: Cadastrar um novo usuário com successo na ServeRest
    Dado que eu deseje criar um usuário novo
    Quando cadastrar o usuário na ServeRest         email=${emailTeste}     status_code_desejado=201
    Então devo conferir se o usuário foi cadastrado corretamente

Cenário 002: Cadastrar um usuário já existente
    Dado que eu deseje criar um usuário novo
    Quando cadastrar o usuário na ServeRest         email=${emailTeste}     status_code_desejado=201
    E repetir o cadastro do usuário
    Então devo verificar se a API não permitiu o cadastro repetido 


Cenário 003: Consultar os dados de um novo usuário
    Dado que eu deseje criar um usuário novo
    Quando cadastrar o usuário na ServeRest         email=${emailTeste}     status_code_desejado=201
    E devo consultar dados do novo usuário
    Então conferir os dados retornados