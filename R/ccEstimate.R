img_to_monochrome = function(img, reduced_size = 1)
{
    img            = (img[,,1] + img[,,2] + img[,,3]) / 3
    img_reduced    = img[c(floor(nrow(img) * (1 - reduced_size)/2): ceiling(nrow(img) * (1 - (1 - reduced_size)/2))),
                         c(floor(ncol(img) * (1 - reduced_size)/2): ceiling(ncol(img) * (1 - (1 - reduced_size)/2)))
                        ]
    
    return(img_reduced)
}

sharpen_edges = function(img, sharpen_filter_size = 15)
{
    matrix_to_sharpen = matrix(0, nrow = sharpen_filter_size, ncol = sharpen_filter_size)
    for(ii in 1:sharpen_filter_size){matrix_to_sharpen[ii, c(ii, sharpen_filter_size - ii + 1)] = -1}
    matrix_to_sharpen[trunc(sharpen_filter_size/2 + 1), trunc(sharpen_filter_size/2 + 1)] = -sum(matrix_to_sharpen) - 1
    
    img_sharpened            = EBImage::filter2(img, matrix_to_sharpen)
    
    if(length(img_sharpened[img_sharpened > 1]) > 0){img_sharpened[img_sharpened > 1] = 1}
    if(length(img_sharpened[img_sharpened < 0]) > 0){img_sharpened[img_sharpened < 0] = 0}
    
    return(img_sharpened)
}

enhance_contrast = function(img, contrast = 2)
{
    img          = img * contrast
    img[img > 1] = 1
    
    return(img)
}

to_binary = function(img)
{
    img_mean   = mean(img)
    img_sd     = sd  (img)
    img_binary = img
    
    img_binary[img >= img_mean + 2 * img_sd | img == 1] = 1
    img_binary[img <  img_mean + 2 * img_sd & img <  1] = 0
    
    return(img_binary)
}

dilate_image = function(img, brush_size = 5, shape = "disc")
{
    kern       = EBImage::makeBrush(brush_size, shape = shape)
    img_dilate = dilate(img, kern)
    
    return(img_dilate)
}

analyze_random_spots = function(img, x = 50)
{
    x0 = sample(1:(nrow(img) - x - 1), size = 1)
    y0 = sample(1:(ncol(img) - x - 1), size = 1)
    
    img_small  = img[x0 + (0:x), y0 + (0:x)]
    confluence = sum(img_small) / length(img_small)
    out        = ifelse(test = confluence > 0.5, yes = 1, no = 0)

    return(out)
}

run_random_spots = function(img, random_image_size = 50, n_random_images = 1000)
{
    confluence = unlist(lapply(1:n_random_images, function(ii){analyze_random_spots(img, random_image_size)}))
    confluence = sum(confluence) / n_random_images
    
    return(confluence)
}

#' Calculate cell confluency.
#' 
#' @param infile Input file (JPG, PNG or TIFF).
#' @param reduced_size Use a sub-image with dimensions reduced_size * width: reduced_size * height. Default = 0.8.
#' @param sharpen_filter_size Size of the sharpen filter. Creates a squared matrix with size sharpen_filter_size: values are -1 on diagonals and center = sharpen_filter_size * 2 -2. Default = 15.
#' @param contrast Contrast value. Default = 2.
#' @param brush_size Brush size. Default = 5.
#' @param shape Brush shape. Can be box, disc, diamond, Gaussian or line. Default = "disc".
#' @param random_image_size Size of random sub-images to be generated. Default = 50.
#' @param n_random_images Number of random images to be generated. Default = 100.
#' @return The confluency level of the image in the input file.
#' @export
#' @examples
#' example_low_confluency = system.file("extdata", "low_confluency.jpg", package = "ccEstimate")
#' example_high_confluency = system.file("extdata", "high_confluency.jpg", package = "ccEstimate")
#' ccEstimate(example_low_confluency)
#' ccEstimate(example_high_confluency)

ccEstimate = function(infile,
                      reduced_size        =    0.8  ,
                      sharpen_filter_size =   15    ,
                      contrast            =    2    ,
                      brush_size          =    5    , 
                      shape               = "disc"  ,
                      random_image_size   =   50    , 
                      n_random_images     = 100
                     )
{
    img           = EBImage::readImage(infile)
    img_single    = img_to_monochrome(img          , reduced_size       )
    img_sharpened = sharpen_edges    (img_single   , sharpen_filter_size)
    img_enhanced  = enhance_contrast (img_sharpened, contrast           )
    img_binary    = to_binary        (img_enhanced       )
    img_dilate    = dilate_image     (img_binary   , brush_size         , shape          )
    confluence    = run_random_spots (img_dilate   , random_image_size  , n_random_images)
    
    return(confluence)
}
