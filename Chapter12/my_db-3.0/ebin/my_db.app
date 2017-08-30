{application, my_db,
[{description, "My Database"},
{vsn, "3.0"},
{modules, [my_db_app, my_db_gen, my_db_sup]},
{registered, [my_db_gen, my_db_sup]},
{applications, [kernel, stdlib]},
{env, []},
{mod, {my_db_app,[]}}]}.
