Will Whitney

## Grounded Language Modeling for Automatic Speech Recognition of Sports Video


1. The paper discusses a grounded language model. What makes a language model grounded? Given a concrete example of how a system might have a grounded model for the word red.

	A grounded language model is one which is informed by the real-world context of the language. That is, a grounded model knows not only what is being said, but something about what that speech refers to, or what is going on that the speaker is referring to. This allows the system to learn something about the real world and how it relates to speech, as in the case of this paper the system learns a relationship between baseball footage and the announcers' statements.
	
	For a system to have a grounded model for 'red', it might have been trained on a large amount of video and text, with the text tending to include the word 'red' whenever the video has something red on-screen. Once this type of system has been trained, it could then identify on its own whether or not the video contained something red.


2. Why does their grounded model perform better at retrieval than a system using carefully checked transcriptions?

	Using only transcriptions, while it can give a fairly good signal, will have its results obscured by the discussion of things that will happen, or could happen, or have already happened. By using the video also, they can filter many of their false positives out of the results.