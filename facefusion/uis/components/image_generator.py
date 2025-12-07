import gradio


def render() -> None:
	"""Render image generator UI component"""
	with gradio.Group():
		with gradio.Row():
			with gradio.Column(scale=1):
				gradio.Markdown("### Image Generator (NSFW Disabled)")

		with gradio.Row():
			gradio.Textbox(
				label='Prompt',
				placeholder='Describe the image you want to generate...',
				lines=3
			)

		with gradio.Row():
			with gradio.Column(scale=1):
				gradio.Slider(
					label='Width',
					value=512,
					minimum=256,
					maximum=1024,
					step=64
				)

			with gradio.Column(scale=1):
				gradio.Slider(
					label='Height',
					value=512,
					minimum=256,
					maximum=1024,
					step=64
				)

		with gradio.Row():
			with gradio.Column(scale=1):
				gradio.Slider(
					label='Steps',
					value=20,
					minimum=1,
					maximum=100,
					step=1
				)

		with gradio.Row():
			with gradio.Column(scale=1):
				gradio.Button('Support on Patreon', link='https://patreon.com')
			with gradio.Column(scale=1):
				gradio.Button('Support on Fund', link='https://fund.facefusion.io')

		with gradio.Row():
			gradio.Image(label='Generated Image', type='pil')


		with gradio.Row():
			gradio.Markdown('**NSFW Filtering: DISABLED ✓**')


def listen() -> None:
	"""Listen to image generator events"""
	pass
