// api/continue-story.js

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
        // 3. Estrai i parametri necessari dal corpo della richiesta
        const { storyHistory, chosenOption, segmentCount } = req.body;
        
        // Ottieni il conteggio dei segmenti o imposta a 1 (il primo segmento è già stato creato)
        const currentSegmentCount = segmentCount || 1;
        
        console.log(`Segmento corrente: ${currentSegmentCount} di 4`);

        // Validazione input
        if (!storyHistory || !chosenOption) {
            return res.status(400).json({ 
                error: 'Parametri mancanti. È necessario fornire storyHistory e chosenOption.' 
            });
        }

        // Log minimizzato
        console.log('Continuazione storia interattiva:');
        console.log('- Opzione scelta:', chosenOption);
        console.log('- Lunghezza storia finora:', storyHistory.length, 'caratteri');

        // Verifica se abbiamo raggiunto il limite di segmenti
        const isFinal = currentSegmentCount >= 4;
        
        // 4. Costruisci il prompt per l'API
        const prompt = `Genera il prossimo segmento di una storia interattiva per bambini. La storia finora è:

${storyHistory}

Scelta fatta: ${chosenOption}

${isFinal ? 'Questo è l\'ultimo segmento della storia (segmento 4 di 4).' : `Questo è il segmento ${currentSegmentCount} di 4.`} Genera un segmento che continui la storia in modo coerente con la scelta fatta.

Il segmento deve:
1. Continuare la storia in modo coerente con la scelta fatta
2. ${isFinal ? 'Concludere la storia in modo soddisfacente' : 'Preparare il terreno per le prossime scelte'}
3. Mantenere un tono adatto ai bambini
4. Essere lungo circa 150-200 parole
5. ${isFinal ? 'Non includere scelte alla fine' : 'Terminare con 2-3 scelte chiare per il lettore'}

Rispondi SOLO con un oggetto JSON nel seguente formato:
{
  "segment": "testo del segmento...",
  "choices": ["scelta 1", "scelta 2", "scelta 3"],
  "is_final": ${isFinal},
  "segmentCount": ${currentSegmentCount + 1}
}`;

        // 5. Prepara la richiesta per OpenRouter
        const apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
        const requestBody = {
            model: 'deepseek/deepseek-chat-v3-0324:free',
            messages: [{ role: 'user', content: prompt }],
            temperature: 0.7,
            response_format: { type: "json_object" }
        };

        // 6. Esegui la chiamata API a OpenRouter con timeout esplicito
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

        // 7. Gestisci la risposta di OpenRouter
        if (!response.ok) {
            throw new Error(`API Error: ${response.status} ${response.statusText}`);
        }

        const data = await response.json();
        const generatedContent = data.choices?.[0]?.message?.content?.trim();
        
        if (!generatedContent) {
            throw new Error('Nessun contenuto generato nella risposta.');
        }

        // 8. Pulizia del contenuto per rimuovere eventuali delimitatori markdown
        let cleanedContent = generatedContent;
        
        // Rimuovi eventuali blocchi di codice markdown (```json ... ```)
        cleanedContent = cleanedContent.replace(/```(json)?\s*/g, '').replace(/\s*```\s*$/g, '');
        
        // Rimuovi caratteri di nuovo riga iniziali e finali
        cleanedContent = cleanedContent.trim();
        
        console.log("Contenuto pulito:", cleanedContent);

        // 9. Parsing e validazione essenziale
        const storyData = JSON.parse(cleanedContent);
        
        if (!storyData.segment || !Array.isArray(storyData.choices) || storyData.is_final === undefined) {
            throw new Error('Formato JSON non valido o incompleto');
        }
        
        // Forzare la coerenza in base al conteggio dei segmenti
        if (isFinal) {
            storyData.is_final = true;
            storyData.choices = [];
            console.log("Forzatura della conclusione della storia (segmento finale)");
        } else {
            storyData.is_final = false;
            if (storyData.choices.length === 0) {
                throw new Error('Il segmento non finale deve avere delle scelte');
            }
        }
        
        // Aggiungi il nuovo conteggio dei segmenti alla risposta
        storyData.segmentCount = currentSegmentCount + 1;
        
        // Invia risposta al client
        return res.status(200).json(storyData);

    } catch (error) {
        console.error('Errore:', error);
        res.status(500).json({ 
            error: 'Errore nella continuazione della storia. Riprova.' 
        });
    }
}; 