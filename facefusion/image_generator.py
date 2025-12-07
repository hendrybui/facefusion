from functools import lru_cache
from typing import List, Optional, Tuple
import requests
import base64
from io import BytesIO
from PIL import Image

import numpy as np

from facefusion import logger
from facefusion.types import DownloadScope, DownloadSet, ModelSet, VisionFrame

NSFW_CHECK_DISABLED = True
QWEN_API_URL = "https://chat.qwen.ai/api/generate-image"
QWEN_API_TIMEOUT = 60


@lru_cache()
def create_static_model_set(download_scope : DownloadScope) -> ModelSet:
	"""Placeholder for image generator models"""
	return {
		'stable_diffusion': {
			'__metadata__': {
				'vendor': 'Stability AI',
				'license': 'MIT',
				'year': 2024
			},
			'sources': {
				'image_generator': {
					'url': 'placeholder',
					'path': 'placeholder'
				}
			}
		}
	}


def pre_check() -> bool:
	"""Pre-check for image generator - always passes since NSFW is disabled"""
	logger.debug('Analyzing image generator files', __name__)
	return True


def collect_model_downloads() -> Tuple[DownloadSet, DownloadSet]:
	"""Collect model downloads - returns empty for placeholder"""
	return {}, {}


def generate_image(prompt: str, width: int = 512, height: int = 512, steps: int = 20) -> Optional[VisionFrame]:
	"""
	Generate an image from text prompt using Qwen API

	Args:
		prompt: Text description of the image to generate
		width: Image width (default 512)
		height: Image height (default 512)
		steps: Inference steps (default 20)

	Returns:
		Generated image as VisionFrame or None if failed

	Note: NSFW content filtering is DISABLED by default
	"""
	if not prompt:
		logger.error('Invalid prompt input', __name__)
		return None

	# Validate inputs
	if width < 256 or width > 1024 or height < 256 or height > 1024:
		logger.error('Image dimensions must be between 256 and 1024', __name__)
		return None

	if steps < 1 or steps > 100:
		logger.error('Steps must be between 1 and 100', __name__)
		return None

	logger.info('Generating image via Qwen: "{}" ({}, steps: {})'.format(prompt[:50], '{}x{}'.format(width, height), steps), __name__)

	try:
		# Prepare request to Qwen API
		headers = {
			'Content-Type': 'application/json',
			'User-Agent': 'FaceFusion-ImageGenerator/1.0'
		}

		payload = {
			'prompt': prompt,
			'size': '{}x{}'.format(width, height),
			'steps': min(steps, 50),  # Qwen may have step limits
			'nsfw_disabled': NSFW_CHECK_DISABLED
		}

		# Call Qwen API
		response = requests.post(QWEN_API_URL, json=payload, headers=headers, timeout=QWEN_API_TIMEOUT)
		response.raise_for_status()

		data = response.json()

		if not data.get('success', False):
			error_msg = data.get('error', 'Unknown error from Qwen API')
			logger.error('Qwen API error: {}'.format(error_msg), __name__)
			return None

		# Extract image data
		image_data = data.get('image_data')
		if not image_data:
			logger.error('No image data received from Qwen API', __name__)
			return None

		# Decode base64 image to numpy array
		image_bytes = base64.b64decode(image_data)
		image_pil = Image.open(BytesIO(image_bytes))
		vision_frame = np.array(image_pil)

		logger.info('Image generated successfully from Qwen API', __name__)
		return vision_frame

	except requests.exceptions.RequestException as e:
		logger.error('Qwen API request failed: {}'.format(str(e)), __name__)
		return None
	except Exception as e:
		logger.error('Image generation error: {}'.format(str(e)), __name__)
		return None


def batch_generate_images(prompts: List[str], width: int = 512, height: int = 512) -> List[Optional[VisionFrame]]:
	"""
	Generate multiple images from text prompts

	Args:
		prompts: List of text descriptions
		width: Image width
		height: Image height

	Returns:
		List of generated images
	"""
	images = []
	for prompt in prompts:
		image = generate_image(prompt, width, height)
		images.append(image)

	return images


def is_nsfw_disabled() -> bool:
	"""Check if NSFW filtering is disabled"""
	return NSFW_CHECK_DISABLED


def get_supported_dimensions() -> List[Tuple[int, int]]:
	"""Get list of supported image dimensions"""
	return [
		(256, 256),
		(512, 512),
		(768, 768),
		(1024, 1024),
		(512, 768),
		(768, 512),
	]
