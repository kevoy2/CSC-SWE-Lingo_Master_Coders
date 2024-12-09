// Test function for the registration feature.
async function register(firstName, lastName, dob, age, email, hashedPassword, language) {
	if(firstName != null && lastName != null && dob != null && age != null && email != null && hashedPassword != null && language != null) {
		const userData = { 
			first_name: firstName,
			last_name: lastName,
			dob: dob,
			age: age,
			email: email,
			password: hashedPassword,
			language: language,
			email_verified: false 
		};
		try {
			const response = await fetch('http://localhost:3000/register', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify(userData),
			});
			const data = await response.json();
			console.log('Server response:', data);
			if (response.ok) {
				return 1;
			} else {
				return 0;
			}
		} catch (error) {
			return 0;
		}
	} else {
		return 0;
	}
}

// Test function for the login feature.
async function login(email, password) {
	if(email != "" && password != "") {
		const loginData = { email: email, password: password };
		try {
			const response = await fetch('http://localhost:3000/login', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
				},
				body: JSON.stringify(loginData),
			});
			const data = await response.json();
			if (response.ok) {
				return 1;
			} else {
				return 0;
			}
		} catch (error) {
			return 0;
		}
	} else {
		return 0;
	}
}

// Test function for the translation api feature.
async function translate(inputText, from, to) {
	const text = inputText;
	const fromLang = from;
	const toLang = to;

	if (text.length <= 1000 && fromLang != "" && toLang != "")  {
		try {
			const apiUrl = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=${fromLang}|${toLang}`;
		
			const response = await fetch(apiUrl);
			const data = await response.json();
			const targetText = data.responseData.translatedText;
			return targetText;
		} catch (error) {
			return 0;
		}
	} else {
		return 0;
	}
}

// Call all test cases.
describe('Registration test cases:', () => {
	it('empty registration', async () => {
	  	expect(await register(null, null, null, null, null, null, null, null)).toBe(0);
	});
  
	it('invalid email', async () => {
	  	expect(await register('Joe', 'One', '1999-01-01', '25', 'x', '123', 'en')).toBe(0);
	});

	it('weak password', async () => {
		expect(await register('Joe', 'One', '1999-01-01', '25', "jbob06479@gmail.com", "1", 'en')).toBe(1);
	});
	
	it('existing account', async () => {
		expect(await register('Joe', 'One', '1999-01-01', '25', "jbob06479@gmail.com", '1', 'en')).toBe(0);
	});
	
	it('successful registration and encryption', async () => {
		expect(await register('Joe', 'Two', '1999-01-01', '25', "joe483408@gmail.com", '123', 'en')).toBe(1);
	});	  
});

describe('Login test cases:', () => {
	it('empty login', () => {
	  	expect(login("", "")).toBe(0);
	});
  
	it('missing email', () => {
	  	expect(login("", "123")).toBe(0);
	});

	it('missing password', () => {
		expect(login("joe483408@gmail.com", "")).toBe(0);
	});

	it('successful login', () => {
		expect(login("joe483408@gmail.com", "123")).toBe(1);
	});
});

describe('Translation test cases:', () => {
	it('adds two numbers correctly', async () => {
	  expect(await translate("", "", "")).toBe(0);
	});
  
	it('missing target language', async () => {
	  expect(await translate("Hello", "en", "")).toBe(0);
	});

	it('missing source language', async () => {
		expect(await translate("Hello", "", "es")).toBe(0);
	});
	
	it('successful translation', async () => {
		expect(await translate("Hello", "en", "es")).toBe('Hola');
	});

	it('duplicate translation', async () => {
		expect(await translate("Hello", "en", "es")).toBe('Hola');
	});
	
	it('special character', async () => {
		expect(await translate("Number #1", "en", "es")).toBe('Número 1');
	});

	it('small translation', async () => {
		expect(await translate("Hello", "en", "ru")).toBe('Здравствуйте');
	});

	it('paragraph translation', async () => {
		expect(await translate("Hello, how is your day going? I hope it is going well.", "en", "es")).toBe('Hola, ¿cómo va tu día? Espero que vaya bien.');
	});
	
	it('exceeds character limit', async () => {
		expect(await translate("Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad. Bad.", "en", "es")).toBe(0);
	});
});

describe('Language Selection test cases:', () => {
	it('selecting no language pairs', async () => {
	  expect(await translate("Hello", "en", "en")).toBe("PLEASE SELECT TWO DISTINCT LANGUAGES");
	});

	it('selecting same language pairs', async () => {
		expect(await translate("Hello.", "es", "es")).toBe("PLEASE SELECT TWO DISTINCT LANGUAGES");
	  });

	it('select only target language', async () => {
		expect(await translate("Hello.", "en", "es")).toBe("Hola.");
	});

	it('select only source language', async () => {
		expect(await translate("Bonjour.", "fr", "en")).toBe("Hello.");
	});

	it('swap button then translate', async () => {
		expect(await translate("Hello.", "en", "fr")).toBe("Bonjour.");
	});
});
