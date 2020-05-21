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
    img_dilate = EBImage::dilate(img, kern)
    
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

organize_files = function(infolder = "", run_example = FALSE)
{
    #if(run_example == TRUE)
    
    infiles = list.files(infolder)    
    x       = data.frame(file          = infiles,
                         path          = paste(infolder, infiles, sep = "/"),
                         udid          =                             unlist(lapply(infiles, function(x){paste(unlist(strsplit(x, "_"))[1:2], collapse = "_")})),
                         sample_id     =                             unlist(lapply(infiles, function(x){      unlist(strsplit(x, "_"))[[3]]                 })),
                         clone         =                             unlist(lapply(infiles, function(x){      unlist(strsplit(x, "_"))[[4]]                 })),
                         passage       =                             unlist(lapply(infiles, function(x){      unlist(strsplit(x, "_"))[[5]]                 })),
                         day           =                             unlist(lapply(infiles, function(x){      unlist(strsplit(x, "_"))[[7]]                 })),
                         flask         = as.numeric(gsub("FL"  , "", unlist(lapply(infiles, function(x){      unlist(strsplit(x, "_"))[[8]]                 })))),
                         view          = as.numeric(gsub("VIEW", "", unlist(lapply(infiles, function(x){      unlist(strsplit(x, "_"))[[9]]                 }))))
                        )

    x$date_acquired =            unlist(lapply(x$path, function(infile){file.info (infile)$mtime}))
    x$confluence    = as.numeric(unlist(lapply(x$path, function(infile){ccEstimate(infile)      })))
    
    return(x)
}

estimate_confluence_by_pos = function(ii, totest, indata, confluence_target = 0.8)
{
    id        = totest[ii, "id"   ]
    flask     = totest[ii, "flask"]
    view      = totest[ii, "view" ]
    this      = indata[indata$id == id & indata$flask == flask & indata$view == view,]
    mod       = lm(confluence ~ date_acquired, data = this)
    intercept = mod$coefficients[[1]]
    slope     = mod$coefficients[[2]]
    out       = totest[ii,]
    out$pred  = (confluence_target - intercept) / slope
    
    return(out)
}

plot_confluence_prediction = function(ii, out_fit, indata, confluence_target = 0.8)
{
    id       = out_fit[ii, "id"   ]
    flask    = out_fit[ii, "flask"]
    pred     = out_fit[ii, "pred" ]
    indata   = indata[indata$id == id & indata$flask == flask,]
    view2col = data.frame(view = sort(unique(indata$view)), color = RColorBrewer::brewer.pal(length(unique(indata$view)), "Spectral"))
    
    plot(as.POSIXct(0, origin = "1970-01-01 0:00:00", tz = ""),1, type = "n", xlim = range(c(indata$date_acquired, pred)), ylim = c(0,1), xlab = "Days", ylab = "Confluence")
    
    mtext(text = paste(id, ", Flask ", flask, sep = ""), side = 3, line = 1.5, font = 2)
    mtext(text = paste("Confluence ", confluence_target * 100, "% on ", as.POSIXct(pred, origin = "1970-01-01 0:00:00", tz = ""), sep = ""), side = 3, line = 0)
    
    abline(h = confluence_target, col = "#FF0000", lty = "dashed")
    
    axis.POSIXct(1, at = seq(min(indata$date), max(indata$date) + 86400, by = "day"), format = "%D")
    legend("topleft", legend = view2col$view, fill = view2col$color, title = "Views")
    
    indata = merge(indata, view2col)
    points(indata$date_acquired, indata$confluence, pch = 21, bg = indata$color, cex = 2)
    
    abline(v = pred, col = "#ff0000", lty = "dashed", lwd = 2)
}

estimate_confluence = function(indata, confluence_target = 0.8, plot_confluence = TRUE)
{
    indata$id         = paste(indata$udid, indata$sample_id, indata$clone, indata$passage, sep = "_")
    indata$id_flask   = paste(indata$id, indata$flask, sep = "_")
    totest            = unique(indata[,c("id", "flask", "view")])
    fit               = as.data.frame(data.table::rbindlist(lapply(1:nrow(totest), function(ii){estimate_confluence_by_pos(ii, totest, indata, confluence_target)})), stringsAsFactors = FALSE)
    out_fit           = aggregate(pred ~ id + flask, data = fit, FUN = median)
    out_fit$pred_date = as.POSIXct(out_fit$pred         , origin = "1970-01-01 0:00:00", tz = "")
    fit    $pred_date = as.POSIXct(fit    $pred         , origin = "1970-01-01 0:00:00", tz = "")
    indata $date      = as.POSIXct(indata $date_acquired, origin = "1970-01-01 0:00:00", tz = "")
    
    if(plot_confluence == TRUE)
    {
        invisible(lapply(1:nrow(out_fit), function(ii){plot_confluence_prediction(ii, out_fit, indata, confluence_target)}))
    }
    
    out           = out_fit[,c("id", "flask", "pred_date")]
    colnames(out) = c("ID", "Flask", "Confluence target date")
    
    return(out)
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

#' Estimate when confluency will reach a predetermined threshold.
#' 
#' @param infolder Input folder where all the images to analyze are stored. Deafult = "".
#' @param run_example Run example data. Default = FALSE.
#' @param confluence_target Confluence at which differentiation should start. Values between 0 and 1. Default = 0.8.
#' @param plot_confluence Plot confluence values at each time point. Default = TRUE
#' @return A data frame with the confluency estimation for each sample and flask analyzed
#' @export
#' @examples
#' run_confluency_estimation(run_example = TRUE)

run_confluency_estimation = function(infolder = "", run_example = FALSE, confluence_target = 0.8, plot_confluence = TRUE)
{
    indata = organize_files(infolder, run_example)
    out    = estimate_confluence(indata, confluence_target, plot_confluence)
    
    return(out)
}

