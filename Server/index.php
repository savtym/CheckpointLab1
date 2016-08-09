<?php

use Phalcon\Loader;
use Phalcon\Mvc\Micro;
use Phalcon\Http\Response;
use Phalcon\Di\FactoryDefault;
use Phalcon\Db\Adapter\Pdo\Mysql as PdoMysql;

$loader = new Loader();

$loader->registerDirs(
    array(
        __DIR__ . '/models/'
    )
)->register();

$di = new FactoryDefault();

$di->set('db', function ()
{
    return new PdoMysql(
        array(
            "host"     => "localhost",
            "username" => "root",
            "password" => "",
            "dbname"   => "genealogy"
        )
    );
});

$app = new Micro($di);

// Get list of all trees
$app->get('/api/trees', function () use ($app)
{
    $phql = "SELECT * FROM Tree";
    $trees = $app->modelsManager->executeQuery($phql);
    $data = array();
    foreach ($trees as $tree) {
        $data[] = array(
            'id'   => $tree->id,
            'author' => $tree->author,
            'title' => $tree->title,
            'count_person' => $tree->count_person
        );
    }
    return json_encode($data);
});

// Get list persons of tree
$app->get('/api/trees/{id:[0-9]+}', function ($id) use ($app)
{
    $phql = "SELECT * FROM Person WHERE tree_ID = $id";
    $persons = $app->modelsManager->executeQuery($phql);
    $data = array();
    foreach ($persons as $person)
    {
        $data[] = array(
            'id'   => $person->id,
            'name' => $person->name,
            'surname' => $person->surname,
            'middle_name' => $person->middle_name,
            'gender_type' => $person->gender_type,
            'mother' => $person->mother,
            'father' => $person->father,
            'tree_ID' => $person->tree_ID
        );
        
    }
    return json_encode($data);
});


// Search person on the ID
$app->get('/api/trees/search/{title}', function ($title) use ($app)
{
    $phql = "SELECT * FROM Tree WHERE title LIKE :title: ORDER BY title";
    $trees = $app->modelsManager->executeQuery(
        $phql,
        array(
            'title' => '%' . $title . '%'
        )
    );

    $data = array();
    foreach ($trees as $tree) {
        $data[] = array(
            'id'   => $tree->id,
            'author' => $tree->author,
            'title' => $tree->title,
            'count_person' => $tree->count_person
        );
    }

    return json_encode($data);
});


// add tree
$app->post('/api/trees', function () use ($app)
{
    $tree = $app->request->getJsonRawBody();
    $phql = "INSERT INTO Tree (author, title) VALUES (:author:, :title:)";
    $status = $app->modelsManager->executeQuery($phql, array(
        'author' => $tree->author,
        'title' => $tree->title 
    ));
    $response = new Response();
    if ($status->success() == true)
    {
        $response->setStatusCode(201, "Created");
        $tree->id = $status->getModel()->id;
        $response->setJsonContent(
            array(
                'status' => 'OK',
                'data'   => $tree
            )
        );
    } 
    else 
    {
        $response->setStatusCode(409, "Conflict");
        $errors = array();
        foreach ($status->getMessages() as $message)
        {
            $errors[] = $message->getMessage();
        }
        $response->setJsonContent(
            array(
                'status'   => 'ERROR',
                'messages' => $errors
            )
        );
    }
    return $response;
});


// Update tree on the ID
$app->put('/api/trees/{id:[0-9]+}', function ($id) use ($app)
{
    $tree = $app->request->getJsonRawBody();
    $phql = "UPDATE Tree SET title = :title:, author = :author:, count_person = :count_person: WHERE id = :id:";
    $status = $app->modelsManager->executeQuery($phql, array(
        'id' => $id,
        'title' => $tree->title,
        'author' => $tree->author,
        'count_person' => $tree->count_person
    ));
    $response = new Response();
    if ($status->success() == true)
    {
        $response->setJsonContent(
            array(
                'status' => 'OK'
            )
        );
    }
    else
    {
        $response->setStatusCode(409, "Conflict");
        $errors = array();
        foreach ($status->getMessages() as $message)
        {
            $errors[] = $message->getMessage();
        }
        $response->setJsonContent(
            array(
                'status'   => 'ERROR',
                'messages' => $errors
            )
        );
    }
    return $response;
});


// Remove tree on the ID
$app->delete('/api/trees/{id:[0-9]+}', function ($id) use ($app)
{
    $phql = "DELETE FROM Tree WHERE id = :id:";
    $status = $app->modelsManager->executeQuery($phql, array(
        'id' => $id
    ));
    $response = new Response();

    if ($status->success() == true) {
        $response->setJsonContent(
            array(
                'status' => 'OK'
            )
        );
    }
    else
    {
        $response->setStatusCode(409, "Conflict");
        $errors = array();
        foreach ($status->getMessages() as $message)
        {
            $errors[] = $message->getMessage();
        }
        $response->setJsonContent(
            array(
                'status'   => 'ERROR',
                'messages' => $errors
            )
        );
    }
    return $response;
});


// Add person
$app->post('/api/person', function () use ($app)
{
    $person = $app->request->getJsonRawBody();
    $phql = "INSERT INTO Person (name, surname, middle_name, gender_type, tree_ID) VALUES (:name:, :surname:, :middle_name:, :gender_type:, :tree_ID:)";
    $status = $app->modelsManager->executeQuery($phql, array(
        'name' => $person->name,
        'surname' => $person->surname,
        'middle_name' => $person->middle_name,
        'gender_type' => $person->gender_type,
        'tree_ID' => $person->tree_ID
    ));

    $response = new Response();
    if ($status->success() == true) 
    {
        $response->setStatusCode(201, "Created");
        $person->id = $status->getModel()->id;
        $response->setJsonContent(
            array(
                'status' => 'OK',
                'data'   => $person
            )
        );
    } 
    else
    {
        $response->setStatusCode(409, "Conflict");
        $errors = array();
        foreach ($status->getMessages() as $message)
        {
            $errors[] = $message->getMessage();
        }
        $response->setJsonContent(
            array(
                'status'   => 'ERROR',
                'messages' => $errors
            )
        );
    }
    return $response;
});


// Update person on the ID
$app->put('/api/person/{id:[0-9]+}', function ($id) use ($app)
{
    $person = $app->request->getJsonRawBody();
    $phql = "UPDATE Person SET name = :name:, surname = :surname:, middle_name = :middle_name:, gender_type = :gender_type:, mother = :mother:, father = :father: WHERE id = :id:";
    $status = $app->modelsManager->executeQuery($phql, array(
        'id' => $id,
        'name' => $person->name,
        'surname' => $person->surname,
        'middle_name' => $person->middle_name,
        'gender_type' => $person->gender_type,
        'mother' => $person->mother,
        'father' => $person->father
    ));
    $response = new Response();
    if ($status->success() == true)
    {
        $response->setJsonContent(
            array(
                'status' => 'OK'
            )
        );
    }
    else
    {
        $response->setStatusCode(409, "Conflict");
        $errors = array();
        foreach ($status->getMessages() as $message)
        {
            $errors[] = $message->getMessage();
        }
        $response->setJsonContent(
            array(
                'status'   => 'ERROR',
                'messages' => $errors
            )
        );
    }
    return $response;
});


// Remove person on the ID
$app->delete('/api/person/{id:[0-9]+}', function ($id) use ($app)
{
    $phql = "DELETE FROM Person WHERE id = :id:";
    $status = $app->modelsManager->executeQuery($phql, array(
        'id' => $id
    ));
    $response = new Response();
    if ($status->success() == true)
    {
        $response->setJsonContent(
            array(
                'status' => 'OK'
            )
        );
    }
    else
    {
        $response->setStatusCode(409, "Conflict");
        $errors = array();
        foreach ($status->getMessages() as $message)
        {
            $errors[] = $message->getMessage();
        }
        $response->setJsonContent(
            array(
                'status'   => 'ERROR',
                'messages' => $errors
            )
        );
    }
    return $response;
});

$app->notFound(function () use ($app) {
    $app->response->setStatusCode(404, "Not Found")->sendHeaders();
    echo 'This is crazy, but this page was not found!';
});

$app->handle();



