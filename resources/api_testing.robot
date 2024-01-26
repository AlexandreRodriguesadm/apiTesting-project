*** Settings ***
Library    RequestsLibrary
Library    String
Library    Collections

*** Keywords ***

Dado que eu deseje criar um usuário novo
    ${random_word}       Generate Random String    length=4                         chars=letters
    ${random_word}       Convert To Lower Case     ${random_word}
    Set Test Variable    ${emailTeste}             ${random_word}@emailteste.com
    Log                  ${emailTeste}

Quando cadastrar o usuário na ServeRest
    [Arguments]    ${email}              ${status_code_desejado}
    ${body}        Create Dictionary
    ...            nome=Homem Torto
    ...            email=${email}
    ...            password=1234
    ...            administrador=true
    Log            ${body}

    Criar Sessão na ServeRest

    ${resposta}    POST On Session
    ...            alias=ServeRest
    ...            url=/usuarios
    ...            json=${body}
    ...            expected_status=${status_code_desejado}

    Log     ${resposta.json()}

    IF  ${resposta.status_code} == 201
        Set Test Variable    ${USER_ID}     ${resposta.json()["_id"]}
    END 

    Set Test Variable    ${RESPOSTA}    ${resposta.json()}

    # dessa forma ${resposta.json()["_id"]} consigo obter o valor "_id"
    #.json é a resposta da nossa api, vai precisar para conferir
    # se o cadastro foi feito com sucesso também é as data's
    # a resposta de uma api rest, ou é uma json ou uma array(lista)
    # library collections trás
    # diversas keywords para conferir a nossa resposta de api.

Criar Sessão na ServeRest

    ${headers}        Create Dictionary    accept=application/json      Content-Type=application/json
    Create Session    alias=ServeRest      url=https://serverest.dev    headers=${headers}

Então devo conferir se o usuário foi cadastrado corretamente
    Log                               ${RESPOSTA}
    Dictionary Should Contain Item    ${RESPOSTA}    message    Cadastro realizado com sucesso
    Dictionary Should Contain Key     ${RESPOSTA}    message    _id


#esse passo confere a resposta de uma requisição API.

E repetir o cadastro do usuário
    Quando cadastrar o usuário na ServeRest    email=${emailTeste}    status_code_desejado=400


Então devo verificar se a API não permitiu o cadastro repetido
    Dictionary Should Contain Item    ${resposta}    message    Este email já está sendo usado

E devo consultar dados do novo usuário
    ${resposta_consulta}    GET On Session      alias=ServeRest                url=/usuarios/${USER_ID}
    Set Test Variable       ${RESP_CONSULTA}    ${resposta_consulta.json()}
#get on session por padrão vai esperar o status 200, mas se você quiser
#você pode definir com "expected status", ou coloca "any" para não conferir o status code

# quando fazemos um post no cadastro do usuario a gente recebe uma resposta um id desse usuario
#pegamos esse valor usamos como variavel para usarmos no Get !

Então conferir os dados retornados
    Log                               ${RESP_CONSULTA}
    Dictionary Should Contain Item    ${RESP_CONSULTA}    nome             Homem Torto
    Dictionary Should Contain Item    ${RESP_CONSULTA}    email            ${emailTeste}
    Dictionary Should Contain Item    ${RESP_CONSULTA}    password         1234
    Dictionary Should Contain Item    ${RESP_CONSULTA}    administrador    true
    Dictionary Should Contain Item    ${RESP_CONSULTA}    _id              ${USER_ID}
    