{application, osp,
	      [{description, "Open Server Platform"},
	      {vsn, "0.4"},
	      {modules, [osp, osp_app, osp_admin, osp_broker, osp_mnesia, osp_socket, osp_proto, osp_servlet, osp_compile, osp_file, osp_sup, osp_web]},
	      {registered, [osp_admin]},
	      {applications, [kernel, sasl, stdlib, os_mon, inets]},
	      {mod, {osp_app, []}}
]}.
