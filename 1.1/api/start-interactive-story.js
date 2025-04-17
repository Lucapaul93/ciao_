// api/start-interactive-story.js

// Utilizziamo node-fetch versione 2 per compatibilità con Vercel serverless
const fetch = require('node-fetch');

module.exports = async (req, res) => {
    // 1. Sicurezza: Accetta solo richieste POST
    if (req.method !== 'POST') {
        res.setHeader('Allow', ['POST']);
        return res.status(405).json({ error: `Method ${req.method} Not Allowed` });
    }

    // 2. Recupera la chiave API dalle variabili d'ambiente
    const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
    if (!OPENROUTER_API_KEY) {
        console.error('Errore: OPENROUTER_API_KEY non è impostata nelle variabili d\'ambiente.');
        return res.status(500).json({ error: 'Internal Server Error: API key not configured.' });
    }

    try {
        // 3. Estrai i filtri dal corpo della richiesta inviata da Flutter
        const {
            ageRange,
            theme,
            mainCharacter,
            setting,
            emotion,
            complexTheme,
            moral,
            childName,
        } = req.body;

        // Logging più conciso
        console.log('Parametri ricevuti per storia interattiva:', JSON.stringify({ 
            ageRange, theme, mainCharacter, setting, emotion, 
            complexTheme, moral, childName 
        }));

        // 4. Determina come gestire il protagonista principale
        let protagonistDescription;
        if (childName && childName.trim()) {
            protagonistDescription = childName;
            if (mainCharacter) {
                protagonistDescription += ` (un ${mainCharacter})`;
            }
        } else {
            protagonistDescription = mainCharacter;
        }

        // 5. Costruisci il prompt per l'API
        const prompt = `Genera l'inizio di una storia interattiva per bambini con i seguenti parametri:

Tema: ${theme}
Personaggio principale: ${protagonistDescription}
Ambiente: ${setting}
Emozione principale: ${emotion}
${complexTheme ? `Tema complesso: ${complexTheme}` : ''}
${moral ? `Morale: ${moral}` : ''}
${childName ? `Nome del bambino: ${childName}` : ''}

La storia deve:
1. Iniziare in modo coinvolgente
2. Presentare il personaggio principale e l'ambientazione
3. Creare una situazione interessante
4. Essere lunga circa 150-200 parole
5. Terminare con 2-3 scelte chiare per il lettore

Questo è il primo segmento di 4. La storia continuerà in base alle scelte del lettore.

Rispondi SOLO con un oggetto JSON nel seguente formato:
{
  "segment": "testo del segmento...",
  "choices": ["scelta 1", "scelta 2", "scelta 3"],
  "is_final": false,
  "segmentCount": 1
}`;

        // 6. Prepara la richiesta per OpenRouter
        const apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
        const requestBody = {
            model: 'deepseek/deepseek-chat-v3-0324:free',
            messages: [{ role: 'user', content: prompt }],
            temperature: 0.7,
            response_format: { type: "json_object" }
        };

        // 7. Esegui la chiamata API a OpenRouter con timeout esplicito
        console.log("Invio richiesta a OpenRouter...");
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 8000); // Timeout a 8 secondi
        
        const response = await fetch(apiUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${OPENROUTER_API_KEY}`
            },
            body: JSON.stringify(requestBody),
            signal: controller.signal
        });
        
        clearTimeout(timeoutId);
        console.log("Risposta ricevuta da OpenRouter. Status:", response.status);

        // 8. Gestisci la risposta di OpenRouter
        if (!response.ok) {
            throw new Error(`API Error: ${response.status} ${response.statusText}`);
        }

        const data = await response.json();
        const generatedContent = data.choices?.[0]?.message?.content?.trim();
        
        if (!generatedContent) {
            throw new Error('Nessun contenuto generato nella risposta.');
        }

        // 9. Pulizia del contenuto per rimuovere eventuali delimitatori markdown
        let cleanedContent = generatedContent;
        
        // Rimuovi eventuali blocchi di codice markdown (```json ... ```)
        cleanedContent = cleanedContent.replace(/```(json)?\s*/g, '').replace(/\s*```\s*$/g, '');
        
        // Rimuovi caratteri di nuovo riga iniziali e finali
        cleanedContent = cleanedContent.trim();
        
        console.log("Contenuto pulito:", cleanedContent);

        // 10. Parsing + validazione rapida
        const storyData = JSON.parse(cleanedContent);
        
        // Validazione essenziale
        if (!storyData.segment || !Array.isArray(storyData.choices)) {
            throw new Error('Formato JSON non valido o incompleto');
        }
        
        // Assicurati che is_final sia false per il primo segmento
        storyData.is_final = false;
        
        // Invia il JSON al client
        return res.status(200).json(storyData);
        
    } catch (error) {
        console.error('Errore:', error);
        res.status(500).json({ 
            error: 'Errore nella creazione della storia interattiva. Riprova.' 
        });
    }
}; 