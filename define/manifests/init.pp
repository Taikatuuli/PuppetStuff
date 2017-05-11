class hello_define {
	define hello_define ($content_variable) {
		file {"$title":
			ensure  => file,
			content => $content_variable,
		}
	}

	hello_define {'/home/taikatuuli/muumimma':
		content_variable => "Hei Muumimamma!\n",
}

   
