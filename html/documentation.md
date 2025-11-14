# LiveTime Programming Language Reference

# static class database
Use this static class to login and logout users from the PocketBase backend.
You can administer the local PocketBase instance at: http://localhost:8090/_
If you want to dive deeper into PocketBase, you can find the complete documentation at: https://pocketbase.io/docs/

*Example:*
```
class User
    string id
    string name
static class app
    User user
    start
        user = await database.getAuthenticatedUser
        refresh
    login: string email, string password
        user = await database.authWithPassword email, password
        refresh
    logout
        database.logout
        user = null
        refresh
```


## Static Functions

### getAuthenticatedUser
Calls the PocketBase authRefresh function to get the authenticated user. Call this function when the application starts.

*Example:*
```
app
    User user
    start
        user = await database.getAuthenticatedUser
        refresh
```

Returns Promise<dynamic>

### authWithPassword
Log in a user with an email and password and return the authenticated user

*Example:*
```
app
   drawLogin
       field model:email, type:email, placeholder:"Email"
       field model:password, type:password, placeholder:"Password"
       button text:"Login", padding:buttonPadding, color:white, backgroundColor:primaryColor
           onClick:
               user = await database.authWithPassword email, password
```

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| email     | string | Required parameter |
| password  | string | Required parameter |

Returns Promise<dynamic>

### signupNewUser
Create a new user and then call authWithPassword to log in the user.
Ensure the user object has a valid email, password and passwordConfirm member variables.

*Example:*
```
app
   User user
   drawSignup
       field model:user.email, type:email, placeholder:"Email"
       field model:user.password, type:password, placeholder:"Choose Password"
       field model:user.passwordConfirm, type:password, placeholder:"Confirm Password"
       button text:"Signup", padding:buttonPadding, color:white, backgroundColor:primaryColor
           onClick:
               await database.signupNewUser user
```

| Parameter | Type    | Description        |
| --------- | ------- | ------------------ |
| user      | dynamic | Required parameter |

Returns Promise<dynamic>

### logout
Log out the current user

*Example:*
```
app
    User user
    logout
        database.logout
        user = null
```


---

# class DatabaseTable<T>
Use this class to add, remove, fetch and update items from a remote PocketBase collection.
The items are stored locally in the member variable "items". Use the functions "get", "find", "where" and "length" to access the local items.
You can also subscribe to changes in the remote PocketBase collection to automatically keep the local items up to date in realtime.


## Member Variables

### string name
The name of the remote PocketBase collection

### T[] items
The items you fetch from the database are stored locally in this list

## Member Functions

### add
Add an item to the database table and the local items and set its id member variable to the id assigned by the database

*Example:*
```
class Item
    string id
    string name
app
    DatabaseTable<Item> items = {name:"items"}
    string newItemName
    draw
        field model:newItemName, placeholder:"Item name"
        button text:"Add", onClick:addItem {name:newItemName}
    addItem: Item item
        await items.add item
        print "Added item to database and assigned id: {item.id}"
        refresh
```

| Parameter | Type | Description                                                          |
| --------- | ---- | -------------------------------------------------------------------- |
| item      | T    | An item with a id member variable of type string that is not set yet |

Returns Promise<void>

### remove
Remove an item from the database table and the local items

*Example:*
```
app
    DatabaseTable<Item> items = {name:"items"}
    draw
        for items as item
            div item.name
            div "Remove item", onClick:items.remove item; refresh
```

| Parameter | Type | Description                                            |
| --------- | ---- | ------------------------------------------------------ |
| item      | T    | An item with a valid id member variable of type string |

Returns Promise<void>

### fetchAll
Fetch all items from the database table and store them locally in the member variable "items"

*Example:*
```
class Item
    string id
    string name
app
    DatabaseTable<Item> items = {name:"items"}
    start
        await items.fetchAll
        refresh
    draw
        for items as item
            div item.name
```

Returns Promise<T[]>

### fetch
Fetch a subset of items from the database table and store them locally in the member variable "items"

*Example:*
```
class Item
    string id
    string userId
    string active
    TimeString created
app
    DatabaseTable<Item> items = {name:"items"}
    User user
    start
        await items.fetch filter:"userId = '{user.id}' && active = true", sort:"-created"
        refresh
    draw
        div "{user.name} has {items.length} active items:"
        for items as item
            div item.name
```

| Parameter | Type   | Description                          |
| --------- | ------ | ------------------------------------ |
| filter    | string | Optional parameter, defaults to null |
| sort      | string | Optional parameter, defaults to null |
| fields    | string | Optional parameter, defaults to null |
| expand    | string | Optional parameter, defaults to null |
| page      | int    | Optional parameter, defaults to 1    |
| perPage   | int    | Optional parameter, defaults to 1000 |
| skipTotal | bool   | Optional parameter, defaults to true |

Returns Promise<T[]>

### fetchOne
Fetch and return a single item from the database table

| Parameter | Type   | Description                          |
| --------- | ------ | ------------------------------------ |
| filter    | string | Optional parameter, defaults to ""   |
| sort      | string | Optional parameter, defaults to null |
| expand    | string | Optional parameter, defaults to null |

Returns Promise<T>

### fetchOneById
Fetch and return a single item from the database by id

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| id        | string | Required parameter |

Returns Promise<T>

### update
Update an item with a valid id member variable in the database table and the local items

*Example:*
```
app
    DatabaseTable<Item> items = {name:"items"}
    drawItem: Item item
        div "{item.name}, active:{item.active}"
        div "Make item active", onClick:items.update item, {active:true}; refresh
```

| Parameter | Type    | Description        |
| --------- | ------- | ------------------ |
| item      | T       | Required parameter |
| update    | dynamic | Required parameter |

Returns Promise<void>

