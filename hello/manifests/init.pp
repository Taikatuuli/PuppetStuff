class hello {
	define hello ($content_variable) {
		file {"$title":
		ensure  => file,
		content => $content_variable,
		}
	}
	
	hello {'/home/hello_define1':
		content_variable => "Hello World. This is first define\n",
	}
}
