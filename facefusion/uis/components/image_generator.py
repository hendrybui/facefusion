from typing import Optional
import gradio

from facefusion import image_generator


def render() -> gradio.Group:
	"""Render image generator UI component"""
	with gradio.Group(label='Image Generator', open=False):
		with gradio.Row():
			prompt_input = gradio.Textbox(
				label='Prompt',
				placeholder='Describe the image you want to generate...',
				lines=3
			)

		with gradio.Row():
			with gradio.Column(scale=1):
				width_slider = gradio.Slider(
					label='Width',
					value=512,
					minimum=256,
					maximum=1024,
					step=64
				)

			with gradio.Column(scale=1):
				height_slider = gradio.Slider(
					label='Height',
					value=512,
					minimum=256,
					maximum=1024,
					step=64
				)

		with gradio.Row():
			with gradio.Column(scale=1):
				steps_slider = gradio.Slider(
					label='Steps',
					value=20,
					minimum=1,
					maximum=100,
					step=1
				)

		with gradio.Row():
			generate_button = gradio.Button('Generate Image', variant='primary')

		with gradio.Row():
			output_image = gradio.Image(label='Generated Image', type='pil')

		with gradio.Row():
			nsfw_status = gradio.Label(
				value='NSFW Filtering: DISABLED ✓',
				show_label=False
			)

	return gradio.Group(
		prompt_input,
		width_slider,
		height_slider,
		steps_slider,
		generate_button,
		output_image,
		nsfw_status
	)


def listen() -> None:
	"""Listen to image generator events"""
	pass


def on_generate_click(prompt: str, width: int, height: int, steps: int) -> Optional[str]:
	"""Handle generate button click"""
	if not prompt.strip():
		return 'Please enter a prompt'

	result = image_generator.generate_image(prompt, int(width), int(height), int(steps))

	if result is None:
		return 'Image generation failed or not configured'

	return result
