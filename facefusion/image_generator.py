from functools import lru_cache
from typing import List, Optional, Tuple

from facefusion import wording, logger
from facefusion.types import DownloadScope, DownloadSet, ModelSet, VisionFrame

NSFW_CHECK_DISABLED = True


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
	logger.debug(wording.get('analyzing_files'), __name__)
	return True


def collect_model_downloads() -> Tuple[DownloadSet, DownloadSet]:
	"""Collect model downloads - returns empty for placeholder"""
	return {}, {}


def generate_image(prompt: str, width: int = 512, height: int = 512, steps: int = 20) -> Optional[VisionFrame]:
	"""
	Generate an image from text prompt

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
		logger.error(wording.get('invalid_input'), __name__)
		return None

	# Validate inputs
	if width < 256 or width > 1024 or height < 256 or height > 1024:
		logger.error('Image dimensions must be between 256 and 1024', __name__)
		return None

	if steps < 1 or steps > 100:
		logger.error('Steps must be between 1 and 100', __name__)
		return None

	logger.info('Generating image: "{}" ({}, steps: {})'.format(prompt[:50], '{}x{}'.format(width, height), steps), __name__)

	# Placeholder for actual generation
	# In production, this would call Stable Diffusion or similar
	logger.error('Image generator is in demo mode - returning placeholder', __name__)

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
